import torch.utils.data as data
import numpy as np
import math
import torch
import os
import errno
import trimesh
from skimage import measure

def showMeshReconstruction(implicit):
    """
    calls marching cubes on the input implicit function sampled in the 3D grid
    and shows the reconstruction mesh
    Args:
        implicit    : implicit function sampled at the grid points
    """    
    verts, triangles, normals, values = measure.marching_cubes(implicit, 0)        

    # Create an empty triangle mesh
    mesh = trimesh.Trimesh(vertices=verts, faces=triangles)    

    # preview mesh in an opengl window implicit you installed pyglet and scipy with pip
    mesh.show()


def normalize_pts(input_pts):
    """
    finds the centroid of the input point cloud, and recenters it to (0,0,0)
    also scales it according to the fursthest point distance
    Args:
        input_pts    : input point cloud
    """        
    center_point = np.mean(input_pts, axis=0)
    center_point = center_point[np.newaxis, :]
    centered_pts = input_pts - center_point

    largest_radius = np.amax(np.sqrt(np.sum(centered_pts ** 2, axis=1)))
    normalized_pts = centered_pts / largest_radius   

    return normalized_pts


def normalize_normals(input_normals):
    """
    ensures normals are unit-length vectors
    Args:
        input_normals    : input normals (of a point cloud)
    """            
    normals_magnitude = np.sqrt(np.sum(input_normals ** 2, axis=1))
    normals_magnitude = normals_magnitude[:, np.newaxis]

    normalized_normals = input_normals / normals_magnitude

    return normalized_normals

class SdfDataset(data.Dataset):
    """
    creates the training dataset to train a neural network approxmating signed distances to point cloud
    """        
    def __init__(self, points=None, normals=None, phase='train', args=None):
        self.phase = phase

        if self.phase == 'test':
            self.bs = args.test_batch
            max_dimensions = np.ones((3, )) * args.max_xyz
            min_dimensions = -np.ones((3, )) * args.max_xyz

            bounding_box_dimensions = max_dimensions - min_dimensions  # compute the bounding box dimensions of the point cloud
            grid_spacing = max(bounding_box_dimensions) / (args.grid_N - 9)  # each cell in the grid will have the same size
            X, Y, Z = np.meshgrid(list(     # create a N x N x N grid of samples to evaluate the SDF produced by the neural network
                np.arange(min_dimensions[0] - grid_spacing * 4, max_dimensions[0] + grid_spacing * 4, grid_spacing)),
                                  list(np.arange(min_dimensions[1] - grid_spacing * 4,
                                                 max_dimensions[1] + grid_spacing * 4,
                                                 grid_spacing)),
                                  list(np.arange(min_dimensions[2] - grid_spacing * 4,
                                                 max_dimensions[2] + grid_spacing * 4,
                                                 grid_spacing)))  
            self.grid_shape = X.shape
            self.samples_xyz = np.array([X.reshape(-1), Y.reshape(-1), Z.reshape(-1)]).transpose()
            self.number_samples = self.samples_xyz.shape[0]
            self.number_batches = math.ceil(self.number_samples * 1.0 / self.bs)

        else:
            # Sample random points around surface point along the normal direction based on
            # a Gaussian distribution described in the assignment page. This is the dataset used during the training. 
            # For the training set, we do this sampling process per each iteration (see code in __getitem__).                  
            # For the validation set, we do this sampling process for one time.            
            self.points = points
            self.normals = normals
            self.sample_std = args.sample_std
            self.bs = args.train_batch
            self.number_points = self.points.shape[0]
            self.number_samples = int(self.number_points * args.N_samples)
            self.number_batches = math.ceil(self.number_samples * 1.0 / self.bs)

            if phase == 'val':          
                samples_indices = np.random.randint(self.number_points, size=(self.number_samples,))
                self.samples_sdf = np.random.normal(scale=(self.sample_std), size=(self.number_samples, 1))  # ground-truth sdf
                samples_ori_xyz = self.points[samples_indices, :]
                samples_normals = self.normals[samples_indices, :]
                self.samples_xyz = samples_ori_xyz + samples_normals * self.samples_sdf

    def __len__(self):
        return self.number_batches

    def __getitem__(self, idx):
        start_idx = idx * self.bs
        end_idx = min(start_idx + self.bs, self.number_samples) 
        if self.phase == 'val':
            xyz = self.samples_xyz[start_idx:end_idx, :]
            gt_sdf = self.samples_sdf[start_idx:end_idx, :]
        elif self.phase == 'train':  # sample points on the fly
            # Sample random points around surface point along the normal direction based on
            # a Gaussian distribution described in the assignment page.
            # For training set, do this sampling process per each iteration.
            this_bs = end_idx - start_idx
            indices = np.random.randint(self.number_points, size=(this_bs, ))
            gt_sdf = np.random.normal(scale=self.sample_std, size=(this_bs, 1))
            ori_xyz = self.points[indices, :]
            ori_normals = self.normals[indices, :]
            xyz = ori_xyz + ori_normals * gt_sdf
        else:
            assert self.phase == 'test'
            xyz = self.samples_xyz[start_idx:end_idx, :]

        if self.phase == 'test':
            return {'xyz': torch.FloatTensor(xyz)}
        else:
            return {'xyz': torch.FloatTensor(xyz), 'gt_sdf': torch.FloatTensor(gt_sdf)}


def mkdir_p(dir_path):
    """
    makes a directory
    Args:
        dir_path    : path to the directory to create
    """        
    try:
        os.makedirs(dir_path)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise