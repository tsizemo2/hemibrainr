#' Download a large set of well-traced skeletonised neurons from FlyWire
#'
#'@description Get a large number of skeletonised neurons from FlyWire. The neuronlist is saved as a
#'  \code{nat::neuronlistfh} object so certain neurons may be read from it
#'  without loading the entire, large \code{neuronlist} into memory. You will need access to the hemibrain Google Team Drive and
#'  have it mounted with Google filestream.The function \code{flywire_neurons_update} can be used to update the available data.
#'  If you want to flag flywire neurons that should be added to the Google drive, without doing this yourself, you can use
#'  \code{flywire_request}.
#'
#' @param brain the brainspace in which hemibrain neurons have been registered. Defaults to raw voxel space for the FlyWire project.
#' @param local \code{FALSE} or path. By default (\code{FALSE}) data is read from \code{options()$Drive_hemibrain_data}), but the user can specify an alternative path.
#' @param mirror logical, whether or not to read neurons that have been mirrored (i.e. flipped to the 'other' brain hemisphere).
#' @param x flywire IDs to update, for the saved Google drive \code{neuronlistfh} objects called with \code{flywire_neurons}.
#' @param request a neuronlist, matrix of x,y,z position or flywire ID to add to a
#' \href{https://docs.google.com/spreadsheets/d/1rzG1MuZYacM-vbW7100aK8HeA-BY6dWAVXQ7TB6E2cQ/edit#gid=0}{Google sheet} that records flywire positions
#' flagged to be processed into neuron skeletons that can be called by \code{flywire_neurons}.
#' @param nblast which flywire NBLAST to update on Google drive.
#' @param selected_file the Google sheet onto which to add new flywire coordinate. I.e. \href{https://docs.google.com/spreadsheets/d/1rzG1MuZYacM-vbW7100aK8HeA-BY6dWAVXQ7TB6E2cQ/edit#gid=0}{Google sheet}.
#' @param sheet the tab onto which to add your requests.
#' @param ... Additional arguments passed to \code{nat::nlapply}.and/or \code{fafbseg::skeletor}.
#'
#' @examples
#' \donttest{
#' \dontrun{
#' fw.neurons = flywire_neurons()
#'}}
#'@return A \code{neuronlist} object containing flywire skeletons. In the meta-data, it might be useful for some users to note that
#'you will get:
#'
##' \itemize{
##'  \item{"flywire.id"}{ The ID given to the corresponding volumetric body in flywire.
##'  These are used to do things like fetch volumes and are the input to the \code{skeletor} function. However, they are highly volatile and
##'  change a lot with active tracing.}
##'  \item{"flywire.xyz"}{ The voxel coordinate of a single point in this neuron, usually a cell body fiber tract position. This is a more accurate way
##'  of keeping tract of neuron as it will always correspond to the same 'neuron' even though its related flywire.id will change with merge/split events in flywire.}
##'  \item{"hemilineage"}{ An estimated hemilineage identity from both of two naming systems, Ito et al. 2013 and Wong et al. 2013}
##'  \item{"side"}{ An estimate as to the 'side', i.e. brain hemisphere, in which the neuron lies}
##'  \item{"skid"}{ The 'skeleton ID' of this neuron's match in CATMAID for FAFBv14}
##'  \item{"FAFB.xyz"}{ The coordinates in nanometers of a point in the neuron, in FAFBv14 space}
##'  \item{"hemibrain_match"}{ The bodyid of an estimated hemibrain match}
##' }
#'
#'@export
#'@seealso \code{\link{hemibrain_read_neurons}}
#'@importFrom utils download.file
#'@importFrom googledrive drive_ls as_id
flywire_neurons <- function(local = FALSE,
                            brain = c("FlyWire", "JRCFIB2018Fraw","JRCFIB2018F","FAFB","FAFB14","JFRC2", "JFRC2013","JRC2018F","FCWB"),
                            mirror = FALSE,
                            ...){
  brain = match.arg(brain)
  if(brain == "JRCFIB2018Fraw"){
    brain = "JRCFIB2018F"
    scale = TRUE
  }else if (brain %in% c("FAFB","FAFB14")){
    brain = "FlyWire"
    scale = FALSE
  }else{
    scale = FALSE
  }

  # Get Google drive folder
  savedir = good_savedir(local = local)
  neuronsdir = paste0(savedir,"flywire_neurons/")
  fhdir = paste0(neuronsdir,brain,"/")

  # Read
  filelist = list.files(path = fhdir, pattern = ".rds", full.names = TRUE)
  filelist = filelist[grepl("mirror",filelist)==mirror]
  filelist = sort(filelist,decreasing = TRUE)
  if(length(filelist)){
    fh.file = filelist[1]
    neurons.fh = nat::read.neuronlistfh(fh.file)
    attr(neurons.fh,"df") = neurons.fh[,]
  }else{
    warning("neuronlistfh (.rds) file not found at: ", fhdir)
    return(NULL)
  }

  # Scale neurons if needs be
  if(scale){
    neurons.fh = scale_neurons(neurons.fh,scaling=8/1000, ...)
  }

  # Return
  neurons.fh
}

#' @rdname flywire_neurons
#' @export
flywire_neurons_update <- function(x,
                                brain = c("FlyWire", "JRCFIB2018F","FAFB","JFRC2", "JFRC2013", "JRC2018F","FCWB"),
                                mirror = FALSE,
                                ...){
  if(!requireNamespace("fafbseg", quietly = TRUE)) {
    stop("Please install fafbseg using:\n", call. = FALSE,
         "remotes::install_github('natverse/fafbseg')")
  }
  brain = match.arg(brain)
  if(!requireNamespace("fafbseg", quietly = TRUE)) {
    stop("Please install fafbseg using:\n", call. = FALSE,
         "remotes::install_github('natverse/fafbseg')")
  }
  if(mirror){
    flip = "_mirrored"
  }else{
    flip = NULL
  }
  message("Skeletonising skelected neurons using skeletor ...")
  y = fafbseg::skeletor(x, brain = elmr::FAFB14.surf, ...)
  y = flywire_basics(y)
  f = flywire_neurons(brain = brain, mirror = mirror)

  # Transform
  if(mirror){
    message("Mirroring neurons version ...")
    m = nat.templatebrains::xform_brain(y, reference = "JRC2", sample = "FAFB14", ...)
    t = nat.templatebrains::mirror_brain(m, brain = "JRC2", ...)
    if(brain!="FlyWire"){
      t = nat.templatebrains::xform_brain(t, sample = "JRC2", reference = brain, ...)
    }
  }else if (brain!="FlyWire"){
    message("Transforming skeletons ...")
    t = nat.templatebrains::xform_brain(y, reference = brain, sample = "FAFB14", ...)
  }else{
    t  = y
  }

  # Add to data
  message("Making neuronlist object ...")
  z = union(t, nat::as.neuronlist(f))

  # Save
  googledrive_upload_neuronlistfh(z,
                                  team_drive = hemibrainr_team_drive(),
                                  file_name = sprintf("flywire_neurons_%s%s.rds", brain, flip),
                                  folder = "flywire_neurons",
                                  subfolder = brain)
}

#' @rdname flywire_neurons
#' @export
flywire_nblast_update <- function(x = NULL,
                                  nblast = c("hemibrain-flywire",
                                             "flywire",
                                             "flywire-mirror"),
                                  ...){
  # neuronlist
  if(!nat::is.neuronlist(x)){
    stop("x must be a neuronlist!")
  }

  # Get old NBLAST
  nblast = match.arg(nblast)
  old.nblast = hemibrain_nblast(nblast)

  # Get neurons to be updated
  message("Loading flywire neurons ...")
  old.nblast = old.nblast[,setdiff(colnames(old.nblast),x)]
  f = flywire_neurons(brain= "JRCFIB2018F")
  if(is.null(x)){
    x = setdiff(names(f),colnames(nblast))
  }
  f = f[names(f) %in% as.character(x)]
  f = nat::dotprops(f, ...)
  m = flywire_neurons(brain= "JRCFIB2018F", mirror = TRUE)
  m = m[names(m) %in% as.character(x)]
  m = nat::dotprops(m, ...)
  names(m) = paste0(names(m),"_m")
  d = union(f, m)

  ### NBLAST native
  message("NBLASTing ...")
  if(nblast=="hemibrain-flywire"){
    # Get hemibrain neurons
    message("Loading hemibrain neurons ...")
    all.neurons.flow.microns.dps = hemibrain_neurons(brain= "JRCFIB2018F", dotprops = TRUE)

    # NBLAST!
    message("NBLASTing hemibrain vs flywire")
    hemibrain.flywire.mean.1 = nat.nblast::nblast(query = d,
                                                  target = all.neurons.flow.microns.dps,
                                                  .parallel=TRUE,
                                                  normalised = TRUE)
    hemibrain.flywire.mean.2 = nat.nblast::nblast(query = all.neurons.flow.microns.dps,
                                                  target = d,
                                                  .parallel=TRUE,
                                                  normalised = TRUE)
    hemibrain.flywire.mean = (hemibrain.flywire.mean.1+t(hemibrain.flywire.mean.2))/2

    ## Average native and mirrored
    colnames(hemibrain.flywire.mean) = gsub("_m$","",colnames(hemibrain.flywire.mean))
    rownames(hemibrain.flywire.mean) = gsub("_m$","",rownames(hemibrain.flywire.mean))
    hemibrain.flywire.mean = collapse_matrix_by_names(hemibrain.flywire.mean, FUN = max)
    hemibrain.flywire.mean[hemibrain.flywire.mean<-0.5]=-0.5
    hemibrain.flywire.mean=round(hemibrain.flywire.mean, digits=3)
    hemibrain.flywire.mean = merge(hemibrain.flywire.mean, old.nblast, all.x = TRUE, all.y = TRUE)

    # Save NBLAST on hemibrain googledrive
    googledrive_upload_nblast(hemibrain.flywire.mean)

  }

  # FlyWire
  if(nblast=="flywire-mirror"){
    # Get hemibrain neurons
    message("Loading hemibrain neurons ...")
    all.fw = flywire_neurons()
    all.fw.dps = nat::dotprops(all.fw, .parallel = TRUE, OmitFailures = TRUE)
    rm("all.fw")
    flywire.mirror.mean.1 = nat.nblast::nblast(query = d,
                                                         target = all.fw.dps,
                                                         .parallel=TRUE,
                                                         normalised = TRUE)
    flywire.mirror.mean.2 = nat.nblast::nblast(query = all.fw.dps,
                                                         target = d,
                                                         .parallel=TRUE,
                                                         normalised = TRUE)
    flywire.mirror.mean = (flywire.mirror.mean.1+t(flywire.mirror.mean.2))/2
    colnames(flywire.mirror.mean) = gsub("_m$","",colnames(flywire.mirror.mean))
    rownames(flywire.mirror.mean) = gsub("_m$","",rownames(flywire.mirror.mean))
    flywire.mirror.mean[flywire.mirror.mean<-0.5]=-0.5
    flywire.mirror.mean=round(flywire.mirror.mean, digits=3)
    flywire.mirror.mean = merge(flywire.mirror.mean, old.nblast, all.x = TRUE, all.y = TRUE)
    googledrive_upload_nblast(flywire.mirror.mean)
  }

  # Just FlyWire left-right
  if(nblast=="flywire"){
    # Get hemibrain neurons
    message("Loading flywire neurons ...")
    all.fw = flywire_neurons()
    all.fw.dps = nat::dotprops(all.fw, .parallel = TRUE, OmitFailures = TRUE)
    rm("all.fw")
    flywire.mirror.mean = nat.nblast::nblast(query = f,
                                                         target = all.fw.dps,
                                                         .parallel=TRUE,
                                                         normalised = TRUE)
    flywire.mean=round(flywire.mean, digits=3)
    flywire.mean[flywire.mean<-0.5]=-0.5
    flywire.mean = merge(flywire.mean, old.nblast, all.x = TRUE, all.y = TRUE)
    googledrive_upload_nblast(flywire.mean)
  }

}


# hidden
flywire_basics <- function(x){
  if(!nat::is.neuronlist(x)){
    stop("x must be a neuronlist")
  }

  # Get xyz for primary branch points
  simp = nat::nlapply(x,nat::simplify_neuron,n=1)
  branchpoints = sapply(simp, function(y) nat::xyzmatrix(y)[ifelse(length(nat::branchpoints(y)),nat::branchpoints(y),max(nat::endpoints(y))),])
  branchpoints = t(branchpoints)
  flywire.xyz = apply(branchpoints, 1, paste, collapse = ";")


  # Get FAFBv14 nm coordinates
  # roots.flywire.raw = scale(roots, scale = 1/c(4, 4, 40), center = FALSE)
  #FAFB.xyz = nat.templatebrains::xform_brain(roots.flywire.raw, sample = "FlyWire", reference = "FAFB14")
  #FAFB.xyz = apply(FAFB.xyz, 1, paste, collapse = ";")
  FAFB.xyz = ""

  # Add
  x[,"flywire.id"] =  names(x)
  x[,"flywire.xyz"] = flywire.xyz
  x[,"FAFB.xyz"] = FAFB.xyz
  x[,"dataset"] = "flywire"
  x[,"id"] = NULL
  x

}

# Add neuron to request Google sheets
#' @rdname flywire_neurons
#' @export
flywire_request <- function(request,
                            selected_file = options()$flywire_flagged_gsheet,
                            sheet = "flywire",
                            ...){
  if(!requireNamespace("fafbseg", quietly = TRUE)) {
    stop("Please install fafbseg using:\n", call. = FALSE,
         "remotes::install_github('natverse/fafbseg')")
  }
  # What kind of request is it?
  type = if(nat::is.neuronlist(request)){
    "neuronlist"
  }else if(is.data.frame(request)|is.matrix(request)){
    if(nrow(nat::xyzmatrix(request))){
      "xyz"
    }else{
      "ids"
    }
  }else{
    "ids"
  }
  message("Request is ", type)

  # Get coordinates
  if(type=='ids'){
    request = fafbseg::skeletor(request, ...)
  }
  if(nat::is.neuronlist(request)){
    fb = flywire_basics(request)
    xyz = do.call(rbind, lapply(fb[,"flywire.xyz"], function(y) strsplit(y,",| |;|:")))
  }else{
    xyz = nat::xyzmatrix(request)
  }

  # Add to Google sheet
  batches = split(1:nrow(xyz), ceiling(seq_along(1:nrow(xyz))/500))
  for(i in batches){
    gsheet_manipulation(FUN = googlesheets4::sheet_append,
                        data = xyz[min(i):max(i),],
                        ss = selected_file,
                        sheet = sheet)
  }
  message("FlyWire positions added")
}




