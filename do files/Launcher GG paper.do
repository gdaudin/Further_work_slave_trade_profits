	
	if lower(c(username)) == "guillaumedaudin" {
		global dir "~/Répertoires GIT/Further_work_slave_trade_profits"
	}

	if lower(c(username)) == "xronkl" {
		global dir "S:\Personal Folders\???"
	}

	cd "$dir"
	global output "$dir/output/"
	global graphs "$dir/graphs"
	



	do "${dir}/do files/Import tstd.do"

	

	*Creating datasets
	do "${dir}/do files/Port shares computation.do"
	do "${dir}/do files/Import external data.do" 
	*do "${dir}/do files/Import data.do" /*606 ventures 685 voyages*/ /*606 ventures 685 voyages*/ This used to work for the individual csv files (ie Venture database KR - new.csv, Cash flow database GD.csv)
	//It is not working anymore because the files have been merged into one single csv file (merged_database.csv)
	do "${dir}/do files/Import data python_merge.do" /*606 ventures 685 voyages*/ /*This works from the post-merged csv files*/
	do "${dir}/do files/Unique voyages db.do" /*This creates a db of voyages in the data*/
	do "${dir}/do files/For careers.do" /*Work on tsdt, enriched when possible with our data*/
	


	
	*Creating an enriched venture dataset
	do "${dir}/do files/Enrich voyages and save ventures.do"
	do "${dir}/do files/Enrich ventures db.do"
	
	/*This introduces the cash flows*/
	do "${dir}/do files/Database for profit and IRR computation.do"
	do "${dir}/do files/Profit computation.do" /*387 ventures and 446 voyages*/
	

	do "${dir}/do files/Descriptive statistics of explaining variables.do"

	do "${dir}/do files/Profit two parts regressions.do"
	
	*do "${dir}/do files/Profit two parts regressions--various hypothesis.do" //a bit long : out for testing//
	

	do "${dir}/do files/Profit one part regressions.do"
blif

	**Descriptive statistics, comparing different hypothesis

	**Various 

	do "${dir}/do files/Length Europe-Europe computation (exploratory).do" /*Not the one we use : exploratory*/
	