import torch
import torch.nn as nn

class CNN(nn.Module):
    def __init__(self, num_classes):
        super(CNN, self).__init__()
        """  
        Network architecture definition.
        """
        self.conv1 = nn.Conv2d(
            1, 
            8, 
            kernel_size=7, 
            stride=1, 
            padding=0, 
            bias=False
        )
        self.batchnorm1 = nn.BatchNorm2d(8)
        self.leakyrelu1 = nn.LeakyReLU(0.01)
        self.maxpool1 = nn.MaxPool2d(
            kernel_size=2, 
            stride=2
        )

        # Step 5 and onwards
        self.conv2_depthwise = nn.Conv2d(
            8,
            8,
            kernel_size=7,
            stride=2,
            padding=0,
            groups=8,
            bias=False
        )
        self.batchnorm2 = nn.BatchNorm2d(8)
        self.leakyrelu2 = nn.LeakyReLU(0.01)
        self.maxpool2 = nn.MaxPool2d(
            kernel_size=2,
            stride=2
        )
        self.conv2_pointwise = nn.Conv2d(
            8,
            16,
            kernel_size=1,
            stride=1,
            padding=0,
            bias=True
        )

        # Step 10 and onwards
        self.conv3_depthwise = nn.Conv2d(
            16,
            16,
            kernel_size=7,
            stride=1,
            padding=0,
            groups=16,
            bias=False
        )
        self.batchnorm3 = nn.BatchNorm2d(16)
        self.leakyrelu3 = nn.LeakyReLU(0.01)
        self.maxpool3 = nn.MaxPool2d(
            kernel_size=2,
            stride=2
        )
        self.conv3_pointwise = nn.Conv2d(
            16,
            32,
            kernel_size=1,
            stride=1,
            padding=0,
            bias=True
        )

        # Step 15
        self.fully_connected = nn.Conv2d(
            32,
            num_classes,
            kernel_size=3,
            stride=1,
            padding=0,
            bias=True
        )
        self._init_weights()

    def _init_weights(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                if m.kernel_size == (1,1) or m == self.fully_connected:
                    nn.init.xavier_uniform_(m.weight)
                else:
                    nn.init.kaiming_uniform_(m.weight, a=0.01, mode='fan_in', nonlinearity='leaky_relu')
                if m.bias is not None:
                    nn.init.constant_(m.bias, 0)

    def forward(self, x):
        """
        Forward pass of the network.
        """
        # Block 1
        x = self.maxpool1(self.leakyrelu1(self.batchnorm1(self.conv1(x))))

        # Block 2
        x = self.conv2_depthwise(x)
        x = self.batchnorm2(x)
        x = self.leakyrelu2(x)
        x = self.maxpool2(x)
        x = self.conv2_pointwise(x)

        # Block 3
        x = self.conv3_depthwise(x)
        x = self.batchnorm3(x)
        x = self.leakyrelu3(x)
        x = self.maxpool3(x)
        x = self.conv3_pointwise(x)

        # Fully Connected
        x = self.fully_connected(x)

        # Flatten
        out = x.view(x.size(0), -1)
        return out
        

class TinyViT(nn.Module):
    def __init__(
        self,
        num_classes: int,
        img_size: int = 112,
        patch_size: int = 8,
        embed_dim: int = 64,
        num_heads: int = 4,
    ):
        super().__init__()
        assert img_size % patch_size == 0, "img_size must be divisible by patch_size"
        self.num_classes = num_classes
        self.img_size = img_size
        self.patch_size = patch_size
        self.embed_dim = embed_dim
        grid = img_size // patch_size
        num_patches = grid * grid
        
        # 1) Embedding Layer, Positional Embedding
        self.patch_embed = nn.Conv2d(1, embed_dim, kernel_size=patch_size, stride=patch_size, bias=True)   
        self.positional_embedding = nn.Parameter(torch.zeros(1, num_patches + 1, embed_dim))
        # 2) Class token
        self.class_token = nn.Parameter(torch.zeros(1,1,embed_dim))

        # 3) Transformer Encoder
        self.transformer_encoder = nn.TransformerEncoder(
            nn.TransformerEncoderLayer(
                d_model=embed_dim,
                nhead=num_heads,
                dim_feedforward=64,
                dropout=0.1,
                activation='gelu',
                batch_first=True
            ),
            num_layers=2
        )

        # 4) Layer Normalization
        self.layer_norm = nn.LayerNorm(embed_dim)

        # 5) Linear Layer
        self.head = nn.Linear(embed_dim, num_classes)

        self._init_weights()

    def _init_weights(self):
        nn.init.xavier_uniform_(self.patch_embed.weight)
        if self.patch_embed.bias is not None:
            nn.init.constant_(self.patch_embed.bias, 0)
        nn.init.xavier_uniform_(self.head.weight)
        if self.head.bias is not None:
            nn.init.constant_(self.head.bias, 0)

        nn.init.trunc_normal_(self.positional_embedding, std=0.02)
        nn.init.trunc_normal_(self.class_token, std=0.02)

    def forward(self, x):
        x = self.patch_embed(x)
        x = x.flatten(2).transpose(1,2)

        class_token = self.class_token.expand(x.shape[0], -1, -1)
        x = torch.cat((class_token, x), dim=1)

        x = x + self.positional_embedding

        x = self.transformer_encoder(x)
        class_out = x[:,0]
        class_out = self.layer_norm(class_out)
        out = self.head(class_out)

        return out        