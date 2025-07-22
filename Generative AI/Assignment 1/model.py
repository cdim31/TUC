import torch.nn as nn
import torch
import torch.nn.functional as F
from torch.nn.utils import weight_norm

class Decoder(nn.Module):
    def __init__(
        self,
        dims,
        dropout=None,
        dropout_prob=0.1,
        norm_layers=(),
        latent_in=(),
        weight_norm_flag=True,
        use_tanh=True
    ):
        super(Decoder, self).__init__()

        ##########################################################
        # <================START MODIFYING CODE<================>
        ##########################################################
        self.leaky_slope = nn.Parameter(torch.tensor(0.1))
        self.dropout = nn.Dropout(dropout_prob)
        self.use_tanh = use_tanh

        # Create the first seven FC layers with weight normalization
        self.fc_layers = nn.ModuleList()
        # Layer 1: 3 -> 512
        self.fc_layers.append(weight_norm(nn.Linear(3, 512)))
        # Layer 2: 512 -> 512
        self.fc_layers.append(weight_norm(nn.Linear(512, 512)))
        # Layer 3: 512 -> 512
        self.fc_layers.append(weight_norm(nn.Linear(512, 512)))
        # Layer 4: 512 -> 509
        self.fc_layers.append(weight_norm(nn.Linear(512, 509)))
        # Layer 5: 512 -> 512
        self.fc_layers.append(weight_norm(nn.Linear(512, 512)))
        # Layer 6: 512 -> 512
        self.fc_layers.append(weight_norm(nn.Linear(512, 512)))
        # Layer 7: 512 -> 512
        self.fc_layers.append(weight_norm(nn.Linear(512, 512)))

        # Layer 8: 512 -> 1
        self.fc8 = nn.Linear(512, 1)
        self.tanh = nn.Tanh() if use_tanh else nn.Identity()

        ##########################################################
        # <================END MODIFYING CODE<================>
        ##########################################################
    
    def forward(self, input):
        ##########################################################
        # <================START MODIFYING CODE<================>
        ##########################################################
        original_input = input
        x = input

        for i in range(7):
            if i == 3:  # Fourth layer
                x = self.fc_layers[i](x)
                x = torch.cat([x, original_input], dim=1)
            else:
                x = self.fc_layers[i](x)
            
            # Learnable Leaky ReLU
            x = torch.where(x >= 0, x, self.leaky_slope * x)
            # Dropout
            x = self.dropout(x)

        # Final layer
        x = self.fc8(x)
        if self.use_tanh:
            x = self.tanh(x)
        return x
        ##########################################################
        # <================END MODIFYING CODE<================>
        ##########################################################
