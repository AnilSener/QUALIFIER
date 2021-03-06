

# add svg anno to the original panel function for xyplot of lattice package
# individual oultiers are colored based on the groups argument which passed through oultier column of dfframe
panel.xyplotEx <-
		function(x, y, type = "p",
				groups = NULL,
				pch = if (is.null(groups)) plot.symbol$pch else superpose.symbol$pch,
				col,
				col.line = if (is.null(groups)) plot.line$col else superpose.line$col,
				col.symbol = if (is.null(groups)) plot.symbol$col else superpose.symbol$col,
				font = if (is.null(groups)) plot.symbol$font else superpose.symbol$font,
				fontfamily = if (is.null(groups)) plot.symbol$fontfamily else superpose.symbol$fontfamily,
				fontface = if (is.null(groups)) plot.symbol$fontface else superpose.symbol$fontface,
				lty = if (is.null(groups)) plot.line$lty else superpose.line$lty,
				cex = if (is.null(groups)) plot.symbol$cex else superpose.symbol$cex,
				fill = if (is.null(groups)) plot.symbol$fill else superpose.symbol$fill,
				lwd = if (is.null(groups)) plot.line$lwd else superpose.line$lwd,
				horizontal = FALSE
				,subscripts
				,dest
				,df
				,plotObjs
				,plotAll=FALSE
				,statsType
				,scatterPar
				,highlight
				,db
				,rFunc=NULL
				,...
				,grid = FALSE, abline = NULL,
				jitter.x = FALSE, jitter.y = FALSE,
				factor = 0.5, amount = NULL,
				identifier = "xyplot")
{
	
#	browser()
	if (all(is.na(x) | is.na(y))) return()
	plot.symbol <- trellis.par.get("plot.symbol")
	plot.line <- trellis.par.get("plot.line")
	superpose.symbol <- trellis.par.get("superpose.symbol")
	superpose.line <- trellis.par.get("superpose.line")
	if (!missing(col))
	{
		if (missing(col.line)) col.line <- col
		if (missing(col.symbol)) col.symbol <- col
	}
	if (missing(grid) && ("g" %in% type)) grid <- TRUE ## FIXME: what if list?
	if (!identical(grid, FALSE))
	{
		if (!is.list(grid))
			grid <- switch(as.character(grid),
					"TRUE" = list(h = -1, v = -1, x = x, y = y),
					"h" = list(h = -1, v = 0, y = y),
					"v" = list(h = 0, v = -1, x = x),
					list(h = 0, v = 0))
		do.call(panel.grid, grid)
	}

	if (!is.null(abline))
	{
		if (is.numeric(abline)) abline <- as.list(abline)
		do.call(panel.abline, abline)
	}
#	browser()	
	
	if (!is.null(groups))
		panel.superpose(x=x, y=y
				,groups = groups
				,panel.groups = panel.xyplotEx
				,subscripts=subscripts
				,dest=dest
				,df=df
				,plotObjs=plotObjs
				,plotAll=plotAll
				,statsType=statsType
				,scatterPar=scatterPar
				,highlight=highlight
				,db=db
#				,rFunc=rFunc
				,...
				,type = type
				,pch = pch
				,col.line = col.line
				,col.symbol = col.symbol
				,font = font
				,fontfamily = fontfamily
				,fontface = fontface
				,lty = lty
				,cex = cex
				,fill = fill
				,lwd = lwd
				,horizontal = horizontal
				,jitter.x = jitter.x
				,jitter.y = jitter.y
				,factor = factor
				,amount = amount
				,grid = FALSE ## grid=TRUE/type="g" already handled
				)
	else
	{
		x <- as.numeric(x)
		y <- as.numeric(y)
		id <- identifier
	
#		dest<-list(...)$dest
		if(!is.null(dest))
		{
			###add svg anno
#		browser()
			rowIds<-subscripts
			#should not subset df since subscripts are global indices to the original dataframe
			
			if ("o" %in% type || "b" %in% type) type <- c(type, "p", "l")
			if ("p" %in% type)
				for(i in 1:length(x))
				{
					curRowID<-rowIds[i]
					curOutRow<-df[curRowID,]
#					browser()
					FileTips <- paste(highlight,"=",curOutRow[, highlight, with = FALSE]," file=",curOutRow$name,sep="")
					RSVGTipsDevice::setSVGShapeToolTip(title=FileTips,sub.special=FALSE)
					#				browser()
					paths <- "f"
					
					if(!file.exists(file.path(dest,"individual")))system(paste("mkdir",file.path(dest,"individual")))
					paths<-tempfile(pattern=paths,tmpdir="individual",fileext=".png")
					if(plotAll!="none"&&!is.null(dest))
					{
						if(curOutRow$outlier||plotAll==TRUE)
						{
							##save the individual plot obj
#                            browser()
							assign(basename(paths),qa.GroupPlot(db,curOutRow,statsType=statsType,par=scatterPar),envir=plotObjs)
							
							RSVGTipsDevice::setSVGShapeURL(paths)	
						}
					}
					
					
					panel.points(x = if (jitter.x) jitter(x[i], factor = factor, amount = amount) else x[i]
							, y = if (jitter.y) jitter(y[i], factor = factor, amount = amount) else y[i],
							cex = cex,
							fill = fill,
							font = font,
							fontfamily = fontfamily,
							fontface = fontface,
							col = col.symbol,
							pch = pch, ...,
							identifier = id)
				}
		}else
		{
			panel.points(x = if (jitter.x) jitter(x, factor = factor, amount = amount) else x,
				y = if (jitter.y) jitter(y, factor = factor, amount = amount) else y,
				cex = cex,
				fill = fill,
				font = font,
				fontfamily = fontfamily,
				fontface = fontface,
				col = col.symbol,
				pch = pch, ...,
				identifier = id)
		}

#		browser()
		if ("l" %in% type)
			panel.lines(x = x, y = y, lty = lty, col = col.line, lwd = lwd,
					..., identifier = id)
		if ("h" %in% type)
		{
			if (horizontal)
				panel.lines(x = x, y = y, type = "H",
						lty = lty, col = col.line, lwd = lwd,
						..., identifier = id)
			else
				panel.lines(x = x, y = y, type = "h",
						lty = lty, col = col.line, lwd = lwd,
						..., identifier = id)
		}
		

		
		## FIXME: should this be delegated to llines with type='s'?
		if ("s" %in% type)
		{
			ord <- if (horizontal) sort.list(y) else sort.list(x)
			n <- length(x)
			xx <- numeric(2*n-1)
			yy <- numeric(2*n-1)
			
			xx[2*1:n-1] <- x[ord]
			yy[2*1:n-1] <- y[ord]
			xx[2*1:(n-1)] <- x[ord][-1]
			yy[2*1:(n-1)] <- y[ord][-n]
			panel.lines(x = xx, y = yy,
					lty = lty, col = col.line, lwd = lwd, ...,
					identifier = id)
		}
		if ("S" %in% type)
		{
			ord <- if (horizontal) sort.list(y) else sort.list(x)
			n <- length(x)
			xx <- numeric(2*n-1)
			yy <- numeric(2*n-1)
			
			xx[2*1:n-1] <- x[ord]
			yy[2*1:n-1] <- y[ord]
			xx[2*1:(n-1)] <- x[ord][-n]
			yy[2*1:(n-1)] <- y[ord][-1]
			panel.lines(x = xx, y = yy,
					lty = lty, col = col.line, lwd = lwd,
					..., identifier = id)
		}
		if ("r" %in% type) panel.lmline(x, y, col = col.line, lty = lty, lwd = lwd, ...)
		if ("smooth" %in% type)
			panel.loess(x, y, horizontal = horizontal,
					col = col.line, lty = lty, lwd = lwd, ...)
		if ("a" %in% type)
			panel.linejoin(x, y, 
					horizontal = horizontal,
					lwd = lwd,
					lty = lty,
					col.line = col.line,
					...)
		
	
		
	}
	
		
	
}
#' @importFrom MASS rlm
panel.xyplot.qa<-function(x,y,rFunc=NULL,...){
#	browser()
	panel.xyplotEx(x=x,y=y,...) 
	#if regression function is supplied, then plot the regression line
	if(!is.null(rFunc))
	{
		
		reg.res<-try(rFunc(y~x),silent=TRUE)
		if(all(class(reg.res)!="try-error"))
		{
			sumry<-summary(reg.res)
			if(class(sumry)=="summary.rlm"){
				coefs<-coef(sumry)
				t.value<-coefs[,"t value"]
				slope<-coefs[2,"Value"]
				intercept<-coefs[1,"Value"]
				df<-summary(reg.res)$df
				pvalues<-pt(abs(t.value),df=df[1],lower.tail=FALSE)
				intercept.p<-pvalues[1]
				slope.p<-pvalues[2]
			}else if (class(sumry)=="summary.lm"){
				pvalues<-coefficients(sumry)[,4]
				slope<-coefficients(sumry)[2,1]
				intercept.p<-pvalues[1]
				slope.p<-pvalues[2]
				
			}	
			if(any(pvalues<0.05))
			{
				regLine.col<-"red"
			}else
			{
				regLine.col<-"black"
			}
			curVp<-current.viewport()
			
			
			panel.text(x=mean(curVp$xscale)
					,y=quantile(curVp$yscale)[4]
					,labels=paste("s=",format(slope*30,digits=2)
							#														," v=",format(var(y),digits=2)
							,"\np=",paste(format(slope.p,digits=2),collapse=",")
					)
					,cex=0.5
			#										,col="white"		
			)
			
			panel.abline(reg.res,col=regLine.col,lty="dashed")
			
		}
	}
}
# add svg anno to the original panel function for boxplot of lattice package
panel.bwplotEx <-
		function(x, y, box.ratio = 1, box.width = box.ratio / (1 + box.ratio),
				horizontal = TRUE,
				pch = box.dot$pch,
				col = box.dot$col,
				alpha = box.dot$alpha,
				cex = box.dot$cex,
				font = box.dot$font,
				fontfamily = box.dot$fontfamily,
				fontface = box.dot$fontface,
				fill = box.rectangle$fill,
				varwidth = FALSE,
				notch = FALSE,
				notch.frac = 0.5
				,...
				,dest
				,subscripts
				,df
				,groupBy
				,plotObjs
				,plotAll=FALSE
				,statsType
				,scatterPar
				,db
				,levels.fos = if (horizontal) sort(unique(y)) else sort(unique(x)),
				stats = boxplot.statsEx,
				coef = 1.5, do.out = TRUE,
				identifier = "bwplot")
{
#	browser()
	if (all(is.na(x) | is.na(y))) return()
	x <- as.numeric(x)
	y <- as.numeric(y)
	
	box.dot <- trellis.par.get("box.dot")
	box.rectangle <- trellis.par.get("box.rectangle")
	box.umbrella <- trellis.par.get("box.umbrella")
	plot.symbol <- trellis.par.get("plot.symbol")
	
	fontsize.points <- trellis.par.get("fontsize")$points
	cur.limits <- current.panel.limits()
	xscale <- cur.limits$xlim
	yscale <- cur.limits$ylim
	
	if (!notch) notch.frac <- 0
	
	rowIds <- subscripts
	df <- df[rowIds,]#we do need subsetting here since boxplot does not use groups argument to superpose plot
#	browser()    
    #make sure groupBy is factorized
    df[, (groupBy):= factor(df[, get(groupBy)])]
    
	if (horizontal)
	{
      blist <-
               tapply(x, factor(y, levels = levels.fos),
                                   stats,
                                   coef = coef,
                                   do.out = do.out)
         blist.stats <- t(sapply(blist, "[[", "stats"))
         blist.out <- lapply(blist, "[[", "out")
         blist.x <- lapply(blist, "[[", "x")
        
         
         blist.height <- box.width # box.ratio / (1 + box.ratio)

		if (varwidth)
		{
			maxn <- max(table(y))
			blist.n <- sapply(blist, "[[", "n")
			blist.height <- sqrt(blist.n / maxn) * blist.height
		}
		
		## start of major changes to support notches
		blist.conf <-
				if (notch)
					t(sapply(blist, "[[", "conf"))
				else
					blist.stats[ , c(2,4), drop = FALSE]
		
		xbnd <- cbind(blist.stats[, 3], blist.conf[, 2],
				blist.stats[, 4], blist.stats[, 4],
				blist.conf[, 2], blist.stats[, 3],
				blist.conf[, 1], blist.stats[, 2],
				blist.stats[, 2], blist.conf[, 1],
				blist.stats[, 3])
		ytop <- levels.fos + blist.height / 2
		ybot <- levels.fos - blist.height / 2
		ybnd <- cbind(ytop - notch.frac * blist.height / 2,
				ytop, ytop, ybot, ybot,
				ybot + notch.frac * blist.height / 2,
				ybot, ybot, ytop, ytop,
				ytop - notch.frac * blist.height / 2)
		
		
		## box
		
		## append NA-s to demarcate between boxes
		xs <- cbind(xbnd, NA_real_)
		ys <- cbind(ybnd, NA_real_)
		
        df[,{

              thisGroupFactor <- .BY[[1]]
              i <- as.integer(thisGroupFactor)
              curGroupID <- as.character(thisGroupFactor)
              curGroup <- .SD
              
      		  population<-as.character(curGroup[1,population])
			groupTips<-paste("pid=",curGroup$pid[1], " ",groupBy,"=",curGroupID
					, " Tube=",curGroup$Tube[1],sep="")
			cur.btw.groups.outliers<-unique(curGroup$gOutlier)
			if(!is.null(dest))
				RSVGTipsDevice::setSVGShapeToolTip(title=groupTips,sub.special=FALSE)
			##lattice plot for outlier group
#			browser()
			if(plotAll!="none"&&!is.null(dest))
			{
				if(cur.btw.groups.outliers||plotAll==TRUE)
				{
#				browser()
					paths <- "s"
					
					if(!file.exists(file.path(dest,"individual")))system(paste("mkdir",file.path(dest,"individual")))
					paths<-tempfile(pattern=paths,tmpdir="individual",fileext=".png")
					
					##can't print right away since there is issue with embeded lattice plot
					##some how it alter the viewport or leves of parent lattice object 
#				browser()
					curPlotObj<-qa.GroupPlot(db,curGroup,statsType=statsType,par=scatterPar)
					if(!is.null(curPlotObj))
					{
						assign(basename(paths),curPlotObj,envir=plotObjs)
						
						RSVGTipsDevice::setSVGShapeURL(paths)
					}
				}
			}
#			browser()
			panel.polygon(t(xs)[,i], t(ys)[,i],
					lwd = box.rectangle$lwd,
					lty = box.rectangle$lty,
					col = fill,
					alpha = box.rectangle$alpha,
					border = ifelse(cur.btw.groups.outliers,"#E41A1C",box.rectangle$col),
					identifier = paste(identifier, "box", sep="."))
			## end of major changes to support notches
			
			
			## whiskers
			
			panel.segments(c(blist.stats[i, 2], blist.stats[i, 4]),
					rep(levels.fos[i], 2),
					c(blist.stats[i, 1], blist.stats[i, 5]),
					rep(levels.fos[i], 2),
					col = box.umbrella$col,
					alpha = box.umbrella$alpha,
					lwd = box.umbrella$lwd,
					lty = box.umbrella$lty,
					identifier = paste(identifier, "whisker", sep="."))
			panel.segments(c(blist.stats[i, 1], blist.stats[i, 5]),
					levels.fos[i] - blist.height / 2,
					c(blist.stats[i, 1], blist.stats[i, 5]),
					levels.fos[i] + blist.height / 2,
					col = box.umbrella$col,
					alpha = box.umbrella$alpha,
					lwd = box.umbrella$lwd,
					lty = box.umbrella$lty,
					identifier = paste(identifier, "cap", sep="."))
			
			## dot
			
			if (all(pch == "|"))
			{
				mult <- if (notch) 1 - notch.frac else 1
				panel.segments(blist.stats[i, 3],
						levels.fos[i] - mult * blist.height / 2,
						blist.stats[i, 3],
						levels.fos + mult * blist.height / 2,
						lwd = box.rectangle$lwd,
						lty = box.rectangle$lty,
						col = box.rectangle$col,
						alpha = alpha,
						identifier = paste(identifier, "dot", sep="."))
			}
			else
			{
				panel.points(x = blist.stats[i, 3],
						y = levels.fos[i],
						pch = pch,
						col = col, alpha = alpha, cex = cex,
						fontfamily = fontfamily,
						fontface = lattice:::chooseFace(fontface, font),
						fontsize = fontsize.points,
						identifier = paste(identifier, "dot", sep="."))
			}
#			browser()
			
			## outliers
			for(curOutInd in which(curGroup[,outlier]))
			{
				
				curOut <- blist.x[[i]][curOutInd]
				if(!is.na(curOut))##due to the reshape,the extra NA lines from other stats were added here need to be filtered out
				{
					curOutRow <- curGroup[curOutInd,]
				
					if(!is.null(dest)&&plotAll!="none")
					{
						FileTips<-paste("uniqueID=",curOutRow[[eval(qa.par.get("idCol"))]]," file=",curOutRow$name,sep="")
						RSVGTipsDevice::setSVGShapeToolTip(title=FileTips,sub.special=FALSE)
						#				browser()
						paths <- "f"
						if(!file.exists(file.path(dest,"individual")))system(paste("mkdir",file.path(dest,"individual")))
						paths<-tempfile(pattern=paths,tmpdir="individual",fileext=".png")
						
						##save the individual plot obj
	#						browser()
						assign(basename(paths),qa.GroupPlot(db,curOutRow,statsType=statsType,par=scatterPar),envir=plotObjs)
						
						
						RSVGTipsDevice::setSVGShapeURL(paths)
						
					}
#					browser()
					
					panel.points(x = curOut,#unlist(blist.out),
#							y = rep(levels.fos[i], lapply(blist.out, length)[[i]]),
                            y = levels.fos[i],
							pch = plot.symbol$pch,
							col = plot.symbol$col,
							alpha = plot.symbol$alpha,
							cex = plot.symbol$cex,
							fontfamily = plot.symbol$fontfamily,
							fontface = lattice:::chooseFace(plot.symbol$fontface, plot.symbol$font),
							fontsize = fontsize.points,
							identifier = paste(identifier, "outlier", sep="."))
				}
			}
			
		}, by = groupBy]
	}
	else
	{
      blist <-
          tapply(y, factor(x, levels = levels.fos),
              stats,
              coef = coef,
              do.out = do.out)
      blist.stats <- t(sapply(blist, "[[", "stats"))
      blist.x <- lapply(blist, "[[", "x")
      
      blist.height <- box.width # box.ratio / (1 + box.ratio)
#      browser()
		if (varwidth)
		{
			maxn <- max(table(x))
			blist.n <- sapply(blist, "[[", "n")
			blist.height <- sqrt(blist.n / maxn) * blist.height
		}
		
		blist.conf <-
				if (notch)
					sapply(blist, "[[", "conf")
				else
					t(blist.stats[ , c(2,4), drop = FALSE])
		
		ybnd <- cbind(blist.stats[, 3], blist.conf[2, ],
				blist.stats[, 4], blist.stats[, 4],
				blist.conf[2, ], blist.stats[, 3],
				blist.conf[1, ], blist.stats[, 2],
				blist.stats[, 2], blist.conf[1, ],
				blist.stats[, 3])
		xleft <- levels.fos - blist.height / 2
		xright <- levels.fos + blist.height / 2
		xbnd <- cbind(xleft + notch.frac * blist.height / 2,
				xleft, xleft, xright, xright,
				xright - notch.frac * blist.height / 2,
				xright, xright, xleft, xleft,
				xleft + notch.frac * blist.height / 2)
		## box
		
		## append NA-s to demarcate between boxes
		xs <- cbind(xbnd, NA_real_)
		ys <- cbind(ybnd, NA_real_)
#		browser()
		df[,{
#              browser()
                thisGroupFactor <- .BY[[1]]
                i <- as.integer(thisGroupFactor)
                curGroupID <- as.character(thisGroupFactor)
    			curGroup <- .SD
    			population <- as.character(curGroup[1,population])
    			groupTips <- paste("pid=",curGroup$pid[1], " ",groupBy,"=",curGroupID
    					, " Tube=",curGroup$Tube[1],sep="")
    			cur.btw.groups.outliers <- unique(curGroup[,gOutlier])
    			if(!is.null(dest))
    				RSVGTipsDevice::setSVGShapeToolTip(title=groupTips,sub.special=FALSE)
    			##lattice plot for outlier group
    			
    			if(plotAll!="none"&&!is.null(dest))
    			{
    				if(cur.btw.groups.outliers||plotAll==TRUE)
    				{
#    				browser()
    					paths <- "s"    					
    					if(!file.exists(file.path(dest,"individual")))system(paste("mkdir",file.path(dest,"individual")))
    					paths <- tempfile(pattern=paths,tmpdir="individual",fileext=".png")
    					
    					##can't print right away since there is issue with embeded lattice plot
    					##some how it alter the viewport or leves of parent lattice object 
    #				browser()
    					curPlotObj <- qa.GroupPlot(db, curGroup
                                                  , statsType = statsType
                                                  , par = scatterPar
                                                  )
    					if(!is.null(curPlotObj))
    					{
    						assign(basename(paths),curPlotObj,envir=plotObjs)
    					
    						RSVGTipsDevice::setSVGShapeURL(paths)
    					}
    				}
    			}
    #			browser()
    			
    			panel.polygon(t(xs)[,i], t(ys)[,i],
    					lwd = box.rectangle$lwd,
    					lty = box.rectangle$lty,
    					col = fill,
    					alpha = box.rectangle$alpha,
    					border = ifelse(cur.btw.groups.outliers,"red",box.rectangle$col),
    					identifier = paste(identifier, "#E41A1C", sep="."))
    			
    			## whiskers
    			
    			panel.segments(rep(levels.fos[i], 2),
    					c(blist.stats[i, 2], blist.stats[i, 4]),
    					rep(levels.fos[i], 2),
    					c(blist.stats[i, 1], blist.stats[i, 5]),
    					col = box.umbrella$col,
    					alpha = box.umbrella$alpha,
    					lwd = box.umbrella$lwd,
    					lty = box.umbrella$lty,
    					identifier = paste(identifier, "whisker", sep="."))
    			
    			panel.segments(levels.fos[i] - blist.height / 2,
    					c(blist.stats[i, 1], blist.stats[i, 5]),
    					levels.fos[i] + blist.height / 2,
    					c(blist.stats[i, 1], blist.stats[i, 5]),
    					col = box.umbrella$col,
    					alpha = box.umbrella$alpha,
    					lwd = box.umbrella$lwd,
    					lty = box.umbrella$lty,
    					identifier = paste(identifier, "cap", sep="."))
    			
    #				browser()
    			## dot
    			
    			if (all(pch == "|"))
    			{
    				mult <- if (notch) 1 - notch.frac else 1
    				panel.segments(levels.fos[i] - mult * blist.height / 2,
    						blist.stats[i, 3],
    						levels.fos[i] + mult * blist.height / 2,
    						blist.stats[i, 3],
    						lwd = box.rectangle$lwd,
    						lty = box.rectangle$lty,
    						col = box.rectangle$col,
    						alpha = alpha,
    						identifier = paste(identifier, "dot", sep="."))
    			}
    			else
    			{
    				panel.points(x = levels.fos[i],
    						y = blist.stats[i, 3],
    						pch = pch,
    						col = col, alpha = alpha, cex = cex,
    						fontfamily = fontfamily,
    						fontface = lattice:::chooseFace(fontface, font),
    						fontsize = fontsize.points,
    						identifier = paste(identifier, "dot", sep="."))
    			}
    			
    			## outliers
                
    				
    			for(curOutInd in which(curGroup[,outlier]))
    			{
    				curOut<-blist.x[[i]][curOutInd]
    				curOutRow<-curGroup[curOutInd,,drop=FALSE]
    				
    				if(!is.null(dest)&&plotAll!="none")
    				{
    					FileTips<-paste("uniqueID=",curOutRow[[eval(qa.par.get("idCol"))]]," file=",curOutRow$name,sep="")
    					RSVGTipsDevice::setSVGShapeToolTip(title=FileTips,sub.special=FALSE)
    	#				browser()
    					paths <- "f"
    					if(!file.exists(file.path(dest,"individual")))system(paste("mkdir",file.path(dest,"individual")))
    					paths<-tempfile(pattern=paths,tmpdir="individual",fileext=".png")
    
    					##save the individual plot obj
    #						browser()
    					assign(basename(paths),qa.GroupPlot(db,curOutRow,statsType=statsType,par=scatterPar),envir=plotObjs)
    					
    					
    					RSVGTipsDevice::setSVGShapeURL(paths)
    					
    				}
    				
    				panel.points(x = levels.fos[i],
    					y = curOut,
    					pch = plot.symbol$pch,
    					col = plot.symbol$col,
    					alpha = plot.symbol$alpha,
    					cex = plot.symbol$cex,
    					fontfamily = plot.symbol$fontfamily,
    					fontface = lattice:::chooseFace(plot.symbol$fontface, plot.symbol$font),
    					fontsize = fontsize.points,
    					identifier = paste(identifier, "outlier", sep="."))
    			
    						
    		  }
              
            }
        , by = groupBy]
        }
	
	
}

# modify orginal stats funtion to return more info in the final output 
boxplot.statsEx<-function (x, coef = 1.5, do.conf = TRUE, do.out = TRUE) 
{
	if (coef < 0) 
		stop("'coef' must not be negative")
	nna <- !is.na(x)
	n <- sum(nna)
	stats <- stats::fivenum(x, na.rm = TRUE)
	iqr <- diff(stats[c(2, 4)])
	if (coef == 0) 
		do.out <- FALSE
	else {
		out <- if (!is.na(iqr)) {
					x < (stats[2L] - coef * iqr) | x > (stats[4L] + coef * 
								iqr)
				}
				else !is.finite(x)
		if (any(out[nna], na.rm = TRUE)) 
			stats[c(1, 5)] <- range(x[!out], na.rm = TRUE)
	}
#	browser()
	
	conf <- if (do.conf) 
		stats[3L] + c(-1.58, 1.58) * iqr/sqrt(n)
	list(stats = stats, n = n, conf = conf,x=x, outInd=if (do.out) which(out&nna)
					else numeric()
			,out = if (do.out) x[out & 
										nna] else numeric())
}



##parse outlier flag and mark outliers by gate color 
panel.xyplot.flowsetEx <- function(x
                                  , outlier
                                  , gp
                                  ,...)
{
#  browser()
  nm <- as.character(x)
  if (length(nm) < 1) return()
  
  thisOutlier <- outlier[[nm]]
  if(!is.null(thisOutlier))
  {
    gp$gate$col<-ifelse(thisOutlier,"red","black")	
  }else
  {
    gp$gate$col<-"black"
  }
  panel.xyplot.flowset(x,gp = gp, ...)  
}



