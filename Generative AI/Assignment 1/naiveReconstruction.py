import argparse
import numpy as np
from skimage import measure
from sklearn.neighbors import KDTree
from utils import showMeshReconstruction

def createGrid(points, resolution=96):
    """
    constructs a 3D grid containing the point cloud
    each grid point will store the implicit function value
    Args:
        points: 3D points of the point cloud
        resolution: grid resolution i.e., grid will be NxNxN where N=resolution
                    set N=16 for quick debugging, use *N=64* for reporting results
    Returns: 
        X,Y,Z coordinates of grid vertices                      
		max and min dimensions of the bounding box of the point cloud 
    """
    max_dimensions = np.max(points,axis=0) # largest x, largest y, largest z coordinates among all surface points
    min_dimensions = np.min(points,axis=0) # smallest x, smallest y, smallest z coordinates among all surface points    
    bounding_box_dimensions = max_dimensions - min_dimensions # com6pute the bounding box dimensions of the point cloud
    max_dimensions = max_dimensions + bounding_box_dimensions/10  # extend bounding box to fit surface (implicit it slightly extends beyond the point cloud)
    min_dimensions = min_dimensions - bounding_box_dimensions/10
    X, Y, Z = np.meshgrid( np.linspace(min_dimensions[0], max_dimensions[0], resolution),
                           np.linspace(min_dimensions[1], max_dimensions[1], resolution),
                           np.linspace(min_dimensions[2], max_dimensions[2], resolution) )    
    
    return X, Y, Z, max_dimensions, min_dimensions

def sphere(center, R, X, Y, Z):
    """
    constructs an implicit function of a sphere sampled at grid coordinates X,Y,Z
    Args:
        center: 3D location of the sphere center
        R     : radius of the sphere
        X,Y,Z coordinates of grid vertices                      
    Returns: 
        implicit    : implicit function of the sphere sampled at the grid points
    """    
    implicit = (X - center[0]) ** 2 + (Y - center[1]) ** 2 + (Z - center[2]) ** 2 - R ** 2 
    return implicit


def naiveReconstruction(points, normals, X, Y, Z):
    """
    surface reconstruction with an implicit function f(x,y,z) representing
    signed distance to the tangent plane of the surface point nearest to each 
    point (x,y,z)
    Args:
        points :  points of the point cloud
		normals:  normals of the point cloud
		X,Y,Z  :  coordinates of grid vertices 
    Returns:
        IF     : implicit function sampled at the grid points
    """

    ##########################################################
    # <================START MODIFYING CODE<================>
    ##########################################################

    """
    Surface reconstruction using signed distance to nearest tangent plane.
    """
    # Flatten grid coordinates to query points
    Q = np.vstack([X.ravel(), Y.ravel(), Z.ravel()]).T
    
    # Build KDTree for nearest neighbor search
    tree = KDTree(points)
    _, idx = tree.query(Q, k=1)
    idx = idx.flatten()  # Flatten indices array
    
    # Retrieve nearest points and their normals
    nearest_points = points[idx]
    nearest_normals = normals[idx]
    
    # Compute vectors from grid points to nearest surface points
    vectors = Q - nearest_points
    
    # Calculate signed distances (dot product with normals)
    signed_distances = np.einsum('ij,ij->i', vectors, nearest_normals)
    
    # Reshape to grid dimensions
    IF = signed_distances.reshape(X.shape)
	
    ##########################################################
    # <================END MODIFYING CODE<================>
    ##########################################################

    return IF 



if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Naive surface reconstruction')
    parser.add_argument('--file', type=str, default = "data/bunny-1000.pts", help='input point cloud filename')
    parser.add_argument('--method', type=str, default = "naive",\
                        help='method to use: naive (naive reconstruction), sphere (just shows a sphere)')
    args = parser.parse_args()

    # load the point cloud
    data = np.loadtxt(args.file)
    points = data[:, :3]   # first 3 entries are x, y, z
    normals = data[:, 3:6] # last 3 entries are normal_x, normal_y, normal_z

    # create grid whose vertices will be used to sample the implicit function
    X,Y,Z,max_dimensions,min_dimensions = createGrid(points, 96)

    if args.method == 'naive':
        print(f'Running naive reconstruction on {args.file}')
        implicit = naiveReconstruction(points, normals, X, Y, Z)
    else:
        # toy implicit function of a sphere
        print(f'Ignoring the input point cloud {args.file}, and instead I will show you a cool sphere!')
        center =  (max_dimensions + min_dimensions) / 2
        R = max( max_dimensions - min_dimensions ) / 4
        implicit =  sphere(center, R, X, Y, Z)

    showMeshReconstruction(implicit)