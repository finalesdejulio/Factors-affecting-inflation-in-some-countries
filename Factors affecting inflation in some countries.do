cls
set more off, permanently
cd "C:\Users\Nguyen Quoc Anh\Documents\Kì 2 năm 3\Kinh tế lượng\Bài cuối kì"
capture log using Panel.log, replace

*ssc install estout, replace 

foreach x in CPI GDPGrowth ExchangeRate UnemploymentRate PPLGrowth FDI {
	import excel "C:\Users\Nguyen Quoc Anh\Documents\Kì 2 năm 3\Kinh tế lượng\Bài cuối kì\Factors affecting inflation in some countries.xlsx", sheet(`x') firstrow clear
	sort Country
	save `x', replace
}

*Noi du lieu
foreach x in CPI GDPGrowth ExchangeRate UnemploymentRate PPLGrowth FDI {
	use CPI, clear
	di "Dang noi voi bien `x'"
	merge 1:1 Country using `x'.dta, keep(match) nogen
	save CPI, replace
}

*Chuyen bang thanh doc
use CPI, clear
reshape long CPI GDPGrowth ExchangeRate UnemploymentRate PPLGrowth FDI, i(Country) j(Year)
sort Country
egen ID = group(Country)
order Country ID CPI GDPGrowth ExchangeRate UnemploymentRate PPLGrowth FDI
xtset ID Year
save Panel507, replace

***Kiem tra tinh dung
foreach x of varlist CPI GDPGrowth UnemploymentRate PPLGrowth {
	di "Kiem tra tinh dung cua chuoi `x'"
			xtunitroot fisher `x', dfuller lags(0)
}
//CPI ExchangeRate UnemploymentRate va PPLGrowth khong dung
gen dCPI = d.CPI
gen dUnemploymentRate = d.UnemploymentRate
gen dPPLGrowth = d.PPLGrowth

drop if dCPI == .
drop if dUnemploymentRate == .
drop if dPPLGrowth == .

***Kiem tra lai tinh dung
foreach x of varlist dCPI GDPGrowth dUnemploymentRate dPPLGrowth {
	di "Kiem tra tinh dung cua chuoi `x'"
			xtunitroot fisher `x', dfuller lags(0)
}

***Su dung cac pp truyen thong OLS, FE, RE

***OLS
eststo OLS: reg  dCPI GDPGrowth dUnemploymentRate dPPLGrowth
est store OLS
ovtest
vif 
estat hettest
//Co hien tuogn phuong sai thay doi, khac phuc bang robust
reg dCPI GDPGrowth dUnemploymentRate dPPLGrowth, robust

***FEM
eststo FE: xtreg  dCPI GDPGrowth dUnemploymentRate dPPLGrowth, fe
est store FE
//Quan sat p-value => Lua chon mo hinh FEM thay vi OLS
xttest3
//Mo hinh FEM co phuong sai sai so thay doi

***REM
eststo RE: xtreg dCPI GDPGrowth dUnemploymentRate dPPLGrowth, re
est store RE
xttest0

***Lua chon FE va RE
hausman FE RE
//Lua chon REM

***Kiem dinh tu tuong quan
xtserial  dCPI GDPGrowth dUnemploymentRate dPPLGrowth

***dua ve gls
xtgls dCPI GDPGrowth dUnemploymentRate dPPLGrowth, corr(psar1) igls



