# THE2D
Implementation and benchmark scripts accompanying the paper:

> **THE2D: A Method to Efficiently Compute Electrostatic Interactions for Slab Geometries using Top-Hat Function**
> Prateek Kumar Pandey, Swarnendu Biswas, Vishal Agarwal
> *Journal of Chemical Theory and Computation* (submitted). DOI: [to be added]

This repository contains C++/OpenMP implementations of methods for computing electrostatic interactions in systems that are periodic in two dimensions (slabs, interfaces, confined films):

1. **2D-PME**, the particle mesh Ewald method for 2D-periodic systems of Kawata and Nagashima [[1](#references)], built on the 2D Ewald formulation of Kawata and Mikami [[2](#references)].
2. **THE2D and THE2D-PME**, a new method introduced in this work. We incorporated a tophat function to eliminate the interactions in the non-periodic direction

It also includes a direct 2D Ewald reference implementation [[3–5](#references)] and the scripts used to generate the timing and accuracy results in the paper and Supporting Information.

---

## Highlights

- **THE2D:** Direct formulation incorporating the top-hat function
- **THE2D-PME:** Particle mesh implementation of THE2D
- **2D-PME:** implementation of Kawata and Mikami's method, used as the baseline mesh-based comparison.
- **Direct 2D Ewald:** reference implementation for accuracy comparisons.
- Reciprocal-space evaluation scaling as O(N log N).
- OpenMP-parallel real- and reciprocal-space kernels.
- Polynomial Approximation for the real-space kernel for faster computation.
---
## Repository Structure

```
.
├── data/                               # Output data for the experiments reported
│   ├── convergence/                    # convergence of THE2D wrt kz
│   ├── final/                          # Final comparison of THE2D-PME with 2D-PME
│   ├── realspace/                      # Results of real space poly. approx. for erfc
│   ├── the2d-pme/                      # Parameter sweep of gamma, grid and order over THE2D-PME
│   └── threading/                      # Results for mutli-threading and scaling of the program 
├── inc/                                # header files
├── run/                                # Test configuration and parameter input files
├── src/
│   ├── dist.cpp                        # Minimum image convention
│   ├── dSFMT.c                         # dSFMT random number generator
│   ├── func.cpp                        # Helper functions for 2D-PME and 2D-EW (Kawata et al.)
│   ├── main.cpp                        # Main file
│   ├── PM2DEwald.cpp                   # THE2D-PME (this work)
│   ├── print.cpp                       # File to print the input POSCAR into different formats
│   ├── real.cpp                        # Real space energy (contains both functions for Exact and Optimized implementation)
│   ├── reci_0.cpp                      # 
│   ├── reci_fftw2.cpp                  # 2D-PME (Kawata & Mikami)
│   ├── reciprocal.c                    # Has functions for THE2D and Direct 2D Ewald (benchmark reference) 
│   ├── screening_coeff2D.cpp           # Helper functions for THE2D and THE2D-PME
│   └── self.c                          # Self energy function
├── Makefile                            
└── README.md
```

---

## Requirements

**C++ code**
- C++17-compatible compiler (GCC ≥ 15.3.0)
- OpenMP
- FFTW3
- GSL ≥ 2.8

**Analysis scripts**
- Python ≥ 3.9
- `numpy`, `pandas`, `matplotlib`

```bash
pip install numpy pandas matplotlib
```

---

## Building

```bash
git clone https://github.com/prateekkp20/THE2D.git
cd THE2D
make clean &&  make GSL_DIR=$HOME/gsl            
```

---
## Computing Energies
To run place the input POSCAR file (for sample see run/POSCAR.kcl168) in the /run folder and excute the following command.

```bash
cd run && ./coulomb.x
```

The '/run' folder contains the files to modify the ewald parameters: charge.in (charge on the ions), ewald.in (particle mesh parameters), input.in (POSCAR file to process), tophat.in (gamma value for tophat function)


## References
 
1. M. Kawata and U. Nagashima, "Particle mesh Ewald method for three-dimensional systems with two-dimensional periodicity," *Chem. Phys. Lett.* **340**, 165–172 (2001).
2. M. Kawata and M. Mikami, "Rapid calculation of two-dimensional Ewald summation," *Chem. Phys. Lett.* **340**, 157–164 (2001).
3. D. E. Parry, "The electrostatic potential in the surface region of an ionic crystal," *Surf. Sci.* **49**, 433–440 (1975). [doi:10.1016/0039-6028(75)90362-3](https://doi.org/10.1016/0039-6028(75)90362-3)
4. D. M. Heyes, M. Barber, and J. H. R. Clarke, "Molecular dynamics computer simulation of surface properties of crystalline potassium chloride," *J. Chem. Soc., Faraday Trans. 2* **73**, 1485–1496 (1977).
5. S. W. de Leeuw and J. W. Perram, "Electrostatic lattice sums for semi-infinite lattices," *Mol. Phys.* **37**, 1313–1322 (1979).

```bibtex
@article{kawata2001pme2d,
  author  = {Kawata, Masaaki and Nagashima, Umpei},
  title   = {Particle mesh {E}wald method for three-dimensional systems with two-dimensional periodicity},
  journal = {Chem. Phys. Lett.},
  volume  = {340},
  number  = {1-2},
  pages   = {165--172},
  year    = {2001}
}

@article{kawata2001ewald2d,
  author  = {Kawata, Masaaki and Mikami, Masuhiro},
  title   = {Rapid calculation of two-dimensional {E}wald summation},
  journal = {Chem. Phys. Lett.},
  volume  = {340},
  number  = {1-2},
  pages   = {157--164},
  year    = {2001}
}
@article{PARRY1975433,
    title = {The electrostatic potential in the surface region of an ionic crystal},
    journal = {Surface Science},
    volume = {49},
    number = {2},
    pages = {433-440},
    year = {1975},
    issn = {0039-6028},
    author = {D.E. Parry},
    doi = {https://doi.org/10.1016/0039-6028(75)90362-3},
}
@article{heyes1977molecular,
  title={Molecular dynamics computer simulation of surface properties of crystalline potassium chloride},
  author={Heyes, DM and Barber, M and Clarke, JHR},
  journal={Journal of the Chemical Society, Faraday Transactions 2: Molecular and Chemical Physics},
  volume={73},
  number={7},
  pages={1485--1496},
  year={1977},
  publisher={Royal Society of Chemistry}
}
@article{de1979electrostatic,
  title={Electrostatic lattice sums for semi-infinite lattices},
  author={De Leeuw, Simon W and Perram, John W},
  journal={Molecular Physics},
  volume={37},
  number={4},
  pages={1313--1322},
  year={1979},
  publisher={Taylor \& Francis}
}
```

## Contact

Prateek Kumar Pandey -  prateekkp26@gmail.com \
Dr. Vishal Agarwal - vagarwal@iitk.ac.in \
Dr. Swarnendu Biswas - swarnendu@cse.iitk.ac.in
