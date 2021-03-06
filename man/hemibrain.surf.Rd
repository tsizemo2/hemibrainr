% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hemibrain_data.R
\docType{data}
\name{hemibrain.surf}
\alias{hemibrain.surf}
\alias{hemibrain_microns.surf}
\title{The hemibrain mesh}
\format{
An object of class \code{hxsurf} (inherits from \code{list}) of length 4.

An object of class \code{hxsurf} (inherits from \code{list}) of length 4.
}
\source{
\url{https://neuprint.janelia.org/}
}
\usage{
hemibrain.surf

hemibrain_microns.surf
}
\description{
A 3D mesh of the overall neuropil structures in the hemibrain volume as a
\code{\link[nat]{hxsurf}} object. Created by Philipp Schlegel from the union
of individual ROIs in FlyEM's hemibrain project (see details). Mesh available
both in raw voxels and in microns.
}
\details{
The hemibrain mesh is watertight and contains no internal structure
  or non-manifold vertices. It is the right thing to use if you want to see
  if things are inside the hemibrain neuropil. Philipp Schlegel used the
  following steps to construct the mesh:

  \enumerate{

  \item Taking all the individual ROIs

  \item Voxelizing them

  \item Combining the voxels into a single image stack

  \item Filling the gaps in between (binary operations + some manual fixing
  in Fiji) \item Using a marching cubes to generate a mesh from the stack

  }

  Note that hemibrain coordinate system does not have the anterior-posterior
  axis aligned with the Z axis.
}
\examples{
\donttest{
library(nat)
\dontrun{
plot3d(hemibrain.surf, alpha=.3, col='grey')

# can also convert to rgl mesh3d object for more control
hemibrain <- as.mesh3d(hemibrain.surf)
rgl::wire3d(hemibrain)
rgl::shade3d(hemibrain, alpha=.3)
rgl::shade3d(hemibrain, alpha=.3, col='grey')
}
}
}
\seealso{
\code{\link{hemibrain_roi_meshes}}, \code{\link{hemibrain_al.surf}}
}
\keyword{datasets}
