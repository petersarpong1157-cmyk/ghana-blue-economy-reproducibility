# INDEPENDENT TERRA RE-EXTRACTION AUDIT — GHANA BLUE ECONOMY
# Tests archived chlorophyll values against monthly NASA chlor_a NetCDF rasters.
# The source panel, source rasters and generated outputs remain on the researcher's local disk.
# This is the fixed script used for the researcher-reported 2026-11-19 RStudio audit.
options(stringsAsFactors = FALSE)
suppressPackageStartupMessages({
  library(data.table)
  library(terra)
})
project_dir <- 'C:/Users/peter/OneDrive/Desktop/blue economy'
output_dir <- file.path(project_dir, 'Blue_Economy_R_Results')
results_dir <- file.path(project_dir, 'Terra_Pixel_Reconciliation_2026')
dir.create(results_dir, recursive=TRUE, showWarnings=FALSE)
panel_candidates <- c(
  file.path(output_dir, 'ghana_coastal_gfw_nasa_spatial_panel.csv'),
  file.path(output_dir, 'ghana_full_grid_month_panel.csv'),
  file.path(project_dir, 'rebuilt_full_panel.csv'),
  file.path(output_dir, 'rebuilt_full_panel.csv'))
panel_path <- panel_candidates[file.exists(panel_candidates)][1L]
if (is.na(panel_path)) stop('No source panel found. Checked:\n',paste(panel_candidates,collapse='\n'))

nc_files <- list.files(project_dir, pattern='\\.nc$', recursive=TRUE,
                       full.names=TRUE, ignore.case=TRUE)
nc_files <- nc_files[grepl('AQUA_MODIS|chlor_a', basename(nc_files),
                          ignore.case=TRUE)]
if (!length(nc_files)) stop('No chlorophyll NetCDFs found under ', project_dir)
parse_month <- function(path) {
  m <- regmatches(basename(path), regexpr('20[0-9]{6}', basename(path)))
  if (!length(m) || !nzchar(m)) return(as.Date(NA))
  as.Date(m, format='%Y%m%d')
}
dates_chr <- vapply(nc_files, function(p) as.character(parse_month(p)), character(1))
if (anyNA(dates_chr)) stop('Some NetCDF filenames have no readable YYYYMMDD date.')
file_dates <- as.Date(dates_chr)
manifest <- data.table(date=file_dates,
  path=normalizePath(nc_files,winslash='/',mustWork=TRUE),
  size_bytes=as.numeric(file.info(nc_files)$size))
manifest[,parent_folder:=dirname(path)]
setorder(manifest,date,path)
fwrite(manifest,file.path(results_dir,'netcdf_discovered_files.csv'))
manifest[,md5:=unname(tools::md5sum(path))]
collision <- manifest[,.(n_files=.N,n_distinct_contents=uniqueN(md5),
  candidate_paths=paste(path,collapse=' | ')),by=date][n_files>1L]
fwrite(collision,file.path(results_dir,'netcdf_duplicate_month_audit.csv'))
conflicts <- collision[n_distinct_contents>1L]
if (nrow(conflicts)) {
  cat('\nCONFLICTING NASA RASTERS FOUND for ',nrow(conflicts),' months.\n',
      'Inspect: ',file.path(results_dir,'netcdf_duplicate_month_audit.csv'),'\n',
      'No source data changed.\n',sep='')
  stop('Same-month NetCDF files differ in content. Cannot safely select automatically.')
}
manifest[,path_length:=nchar(path)]
setorder(manifest,date,path_length,path)
selected <- manifest[!duplicated(date)]
if (nrow(selected)!=80L) {
  cat('Found ',nrow(selected),' distinct NASA months; expected 80.\n',sep='')
  stop('NASA source collection has an unexpected number of months.')
}
fwrite(selected[,.(date,path,size_bytes,md5)],
       file.path(results_dir,'netcdf_selected_80_files.csv'))
nc_files <- selected$path
file_dates <- selected$date
cat('Selected ',length(nc_files),' unique original monthly files; ',
    nrow(manifest)-length(nc_files),' identical duplicate copies safely ignored.\n',sep='')

panel <- fread(panel_path)
required <- c('date','lat','lon','chlor_a_mg_m3')
if (!all(required %in% names(panel))) stop('Panel must contain ',
  paste(required,collapse=', '),'. Found: ',paste(names(panel),collapse=', '))
panel[,date:=as.Date(date)]
panel <- panel[!is.na(lat)&!is.na(lon)&!is.na(date)]
if (!('cell_id' %in% names(panel))) panel[,cell_id:=paste(lat,lon,sep='_')]
setkey(panel,date,cell_id)
if (nrow(unique(panel,by=c('date','cell_id')))!=nrow(panel))
  stop('Multiple records per month/cell; check panel keys.')
tol <- 1e-5
same_value <- function(a,b) {
  (is.na(a)&is.na(b))|(!is.na(a)&!is.na(b)&abs(a-b)<=tol)
}
audit_rows <- vector('list',length(nc_files))
monthly <- vector('list',length(nc_files))
edge_rows <- vector('list',length(nc_files))
for (k in seq_along(nc_files)) {
  file <- nc_files[k];d <- file_dates[k]
  p <- panel[date==d]
  if (!nrow(p)) {cat('No archived panel rows for',as.character(d),'\n');next}
  r <- tryCatch(terra::rast(file,subds='chlor_a'),
    error=function(e) terra::rast(file))
  if (terra::nlyr(r)!=1L) stop('Expected one chlor_a raster layer in ',file)
  if (!terra::is.lonlat(r)) stop('Raster is not longitude/latitude: ',file)
  xy <- as.matrix(p[,.(lon,lat)])
  pts <- terra::vect(as.data.frame(p[,.(lon,lat)]),
                     geom=c('lon','lat'),crs='EPSG:4326')
  ext_original <- as.numeric(terra::extract(r,pts,ID=FALSE)[[1]])
  ext_simple <- as.numeric(terra::extract(r,pts,ID=FALSE,
                                         method='simple')[[1]])
  if (!all(same_value(ext_original,ext_simple)))
    stop('Explicit simple vs default extraction differ for ',file)
  c0 <- terra::cellFromXY(r,xy)
  by_cell <- rep(NA_real_,length(c0));ok <- !is.na(c0)
  if (any(ok)) by_cell[ok] <- as.numeric(terra::values(r,mat=FALSE)[c0[ok]])
  clean <- function(z) {z[!is.finite(z)|z<0]<-NA_real_;z}
  original <- clean(as.numeric(p$chlor_a_mg_m3))
  extracted <- clean(ext_original);by_cell <- clean(by_cell)
  agree <- same_value(original,extracted)
  cat(sprintf('Month %s  archived=%d  mismatch=%d\n',d,nrow(p),sum(!agree)))
  bad <- which(!agree)
  edge <- data.table()
  if (length(bad)) {
    rc <- terra::rowColFromCell(r,c0[bad])
    nr <- terra::nrow(r);nc <- terra::ncol(r)
    vals <- terra::values(r,mat=FALSE)
    near <- lapply(seq_along(bad),function(j) {
      thisrow <- rc[j,1];thiscol <- rc[j,2]
      candidates <- expand.grid(row=(thisrow-1L):(thisrow+1L),
                                col=(thiscol-1L):(thiscol+1L))
      candidates <- candidates[candidates$row>=1&candidates$row<=nr&
        candidates$col>=1&candidates$col<=nc,,drop=FALSE]
      ci <- terra::cellFromRowCol(r,candidates$row,candidates$col)
      values <- clean(as.numeric(vals[ci]));target <- original[bad[j]]
      if (is.na(target)||all(is.na(values)))
        return(data.table(neighbor_error=NA_real_,row_shift=NA_integer_,
                          col_shift=NA_integer_,neighbor_value=NA_real_))
      ix <- which.min(abs(values-target))
      data.table(neighbor_error=abs(values[ix]-target),
                 row_shift=as.integer(candidates$row[ix]-thisrow),
                 col_shift=as.integer(candidates$col[ix]-thiscol),
                 neighbor_value=values[ix])
    })
    edge <- cbind(data.table(date=d,cell_id=p$cell_id[bad],
      lat=p$lat[bad],lon=p$lon[bad],archived=original[bad],
      terra_extracted=extracted[bad],cell_index=c0[bad]),rbindlist(near))
  }
  edge_rows[[k]] <- edge
  rx <- terra::res(r)[1];ry <- terra::res(r)[2]
  px <- (p$lon-terra::xmin(r))/rx
  py <- (terra::ymax(r)-p$lat)/ry
  dist_x <- abs(px-round(px));dist_y <- abs(py-round(py))
  audit_rows[[k]] <- data.table(date=d,cell_id=p$cell_id,lat=p$lat,lon=p$lon,
    archived=original,terra_extracted=extracted,cell_value=by_cell,
    agreement=agree,archived_present=!is.na(original),
    terra_present=!is.na(extracted),
    near_vertical_boundary=dist_x<1e-8,
    near_horizontal_boundary=dist_y<1e-8,
    x_boundary_distance=dist_x,y_boundary_distance=dist_y)
  monthly[[k]] <- data.table(date=d,file=basename(file),n_records=nrow(p),
    n_matches=sum(agree),n_mismatches=sum(!agree),
    numeric_mismatches=sum(!is.na(original)&!is.na(extracted)&
                           abs(original-extracted)>tol),
    archived_only=sum(!is.na(original)&is.na(extracted)),
    terra_only=sum(is.na(original)&!is.na(extracted)),
    cell_addressing_disagreements=sum(!same_value(extracted,by_cell)),
    mismatches_on_vertical_boundary=sum(!agree&dist_x<1e-8),
    mismatches_on_horizontal_boundary=sum(!agree&dist_y<1e-8))
}
all_audit <- rbindlist(audit_rows,fill=TRUE)
month_audit <- rbindlist(monthly,fill=TRUE)
edge_audit <- rbindlist(edge_rows,fill=TRUE)
if (!nrow(all_audit)) stop('No matched source dates were found.')
fwrite(month_audit,file.path(results_dir,'terra_monthly_comparison.csv'))
fwrite(all_audit[agreement==FALSE],
  file.path(results_dir,'terra_all_mismatched_records.csv'))
fwrite(edge_audit,file.path(results_dir,'terra_neighbor_pixel_diagnostics.csv'))
summary <- month_audit[,.(months_checked=.N,records_checked=sum(n_records),
  n_mismatches=sum(n_mismatches),numeric_mismatches=sum(numeric_mismatches),
  archived_only=sum(archived_only),terra_only=sum(terra_only),
  cell_addressing_disagreements=sum(cell_addressing_disagreements),
  mismatches_on_vertical_boundary=sum(mismatches_on_vertical_boundary))]
fwrite(summary,file.path(results_dir,'terra_verification_summary.csv'))
writeLines(capture.output({
  print(sessionInfo());cat('\nTERRA PACKAGE VERSION:\n')
  print(packageVersion('terra'))}),
  file.path(results_dir,'R_terra_session_info.txt'))
cat('\nSOURCE PANEL:',panel_path,'\nNETCDF FILES:',length(nc_files),'\n')
print(summary)
cat('\nNEIGHBOR MATCHES (<=1e-5):',
 if(nrow(edge_audit)) sum(edge_audit$neighbor_error<=tol,na.rm=TRUE) else 0L,
 '\n')
cat('\nOUTPUTS:',results_dir,'\n')
cat('NOTE: Matching current terra does not prove the historical terra version.\n')
