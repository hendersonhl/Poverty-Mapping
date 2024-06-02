*!qwreshape
* Paul Corral

cap prog drop qwreshape
prog define qwreshape, eclass
	version 15, missing
	#delimit;
	syntax varlist (max=1),
	[
	UNIQue(varlist)
	COLumn(varlist max=1)
	PREfix(string)
	direct
	];
	#delimit cr
	
	/*
	if (missing("`direct'")){
		tempvar bby
		egen `bby' = group(`unique')
		local launica `bby'
	}
	else local launica `unique'
	*/
	local launica `unique'
	local _numU : list sizeof unique
	qui:levelsof `column', local(lavar)
	foreach x of local lavar{
		local nomvar `nomvar' `prefix'_`x'
	}
	
	qui:putmata x_l = (`launica' `column' `varlist')
	mata: _sort(x_l,(2,1))
	mata: info = panelsetup(x_l,2)
	mata: st_local("_totobs", strofreal(info[1,2]))
	mata: uniq = x_l[|1,1 \ `_totobs',`_numU'|]	
	mata: _x = x_l[|1,`=`_numU'+2' \ rows(x_l),cols(x_l)|]
	mata: _x = _wideshaper(_x,info)	
	mata: mata drop x_l	
	
	clear
	qui:set obs `_totobs'
	qui:getmata (`unique') = uniq, double	
	qui:getmata (`nomvar') = _x	, double
end	
	
mata

function _wideshaper(x_l, info){
	rr  = rows(info)
	col = cols(x_l)
	i=1
	s = x_l[|info[i,1],1\info[i,2],col|]
	for(i=2;i<=rr;i++){
		s = s,x_l[|info[i,1],1\info[i,2],col|]
	}
	return(s)
}

end
	
	

	
	
	
