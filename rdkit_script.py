import sys
from rdkit import rdBase, Chem, Geometry
from rdkit.Chem import AllChem, Draw
import re
print('RDKit version: ',rdBase.rdkitVersion)

elements_filename = 'elements.txt'
connections_filename = 'connections.txt'
alt_elements_filename = 'two_d_elements.txt'
alt_connections_filename = 'two_d_connections.txt'
rings_filename = 'rings.txt'

# Code from https://github.com/pschwllr/MolecularTransformer
def smi_tokenizer(smi):
    """
    Tokenize a SMILES molecule or reaction
    """
    pattern =  "(\[[^\]]+]|Br?|Cl?|N|O|S|P|F|I|b|c|n|o|s|p|\(|\)|\.|=|#|-|\+|\\\\|\/|:|~|@|\?|>|\*|\$|\%[0-9]{2}|[0-9])"
    regex = re.compile(pattern)
    tokens = [token for token in regex.findall(smi)]
    assert smi == ''.join(tokens)
    return ' '.join(tokens)


def smiles_to_files(smiles):
    mol = Chem.MolFromSmiles(smiles)
    if not mol:
        raise ValueError("Invalid SMILES string")
    mol = Chem.rdmolops.AddHs(mol, explicitOnly = True)
    
    AllChem.EmbedMolecule(mol)

    smiles_tokens = smi_tokenizer(smiles)


    # extract the smiles string from the molecule
    # smi_string = Chem.MolToSmiles(mol)
    with open('smiles.txt', 'w') as smiles_file:
        # print the original SMILES string
        smiles_file.write(smiles_tokens + '\n')

    non_existent_atoms = []
    
    # Output elements and their positions in 3d space
    with open(elements_filename, 'w') as elements_file:
        # C1=CN=C(N=C1)[NH2+]S(=[OH+])(=O)C2=CC=CC=C2N.[Ag+] 

        # Get the largest fragment
        frags = Chem.GetMolFrags(mol, asMols=False)
        largest_frag_atoms = max(frags, key=len)
        

        for atom in mol.GetAtoms():
            position = mol.GetConformer().GetAtomPosition(atom.GetIdx())
            atom_charge = atom.GetFormalCharge()
            if atom.GetIdx() in largest_frag_atoms:
                elements_file.write(f"{atom.GetSymbol()} {atom.GetIdx()} {position.x} {position.y} {position.z} {atom_charge}\n")
            else:
            # if the atom is not in the largest fragment, set its position to -1
                elements_file.write(f"{atom.GetSymbol()} {atom.GetIdx()} -1 -1 -1 {atom_charge}\n")
                non_existent_atoms.append(atom.GetIdx())
    
    # Output connections
    with open(connections_filename, 'w') as connections_file:
        for bond in mol.GetBonds():
            # Check if the bond is between atoms that don't exist in the largest fragment
            if bond.GetBeginAtomIdx() in non_existent_atoms or bond.GetEndAtomIdx() in non_existent_atoms:
                continue
            connections_file.write(f"{bond.GetBeginAtomIdx()} - {bond.GetEndAtomIdx()} - {bond.GetBondTypeAsDouble()}\n")
    
    # Output elements and their positions in 2d space
    Chem.rdCoordGen.AddCoords(mol)
    drawer = Draw.MolDraw2DCairo(1280, 720)
    drawer.drawOptions().fixedBondLength = 40
    drawer.DrawMolecule(mol)
    drawer.FinishDrawing()

    conf = mol.GetConformer()
    with open(alt_elements_filename, 'w') as alt_elements_file:
        for atom in mol.GetAtoms():
            position = conf.GetAtomPosition(atom.GetIdx())
            atom_charge = atom.GetFormalCharge()
            pos_point = Geometry.Point2D(position.x, position.y)
            dpos = drawer.GetDrawCoords(pos_point)
            alt_elements_file.write(f"{atom.GetSymbol()} {atom.GetIdx()} {dpos.x} {dpos.y} {atom_charge}\n")
    
    # Output connections
    with open(alt_connections_filename, 'w') as connections_file:
        for bond in mol.GetBonds():
            # Check if the bond is between atoms that don't exist in the largest fragment
            connections_file.write(f"{bond.GetBeginAtomIdx()} - {bond.GetEndAtomIdx()} - {bond.GetBondTypeAsDouble()}\n")

    # Output the rings
    with open(rings_filename, 'w') as rings_file:
        for ring in mol.GetRingInfo().AtomRings():
            rings_file.write(' '.join(map(str, ring)) + '\n')

if __name__ == "__main__":
    args = sys.argv[1:]
    print("Runtime arguments:", args)
    smiles_to_files(args[0].strip())