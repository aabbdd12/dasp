


ns utiliser le poids de sondage */
// Exercice 2 ****1%
Q2.
/*estimation des dépenses moyennes par équivalent adult          e */  adulte sa
imean ae_exp

//  Exercice 3***4.5%
//Q3.1: 
/*calcul de la taille de la population */

sum hsize 

//  Q3.2: 

/* Ordonnez les depenses par habitant en ordre croissant */ 
sort ae_exp

/* generer  la variable part de population (ps) */
sum hsize
gen ps = hsize/r(sum)

/* generer les variables centiles (p) et quantiles (q). */ 
gen p = sum(ps)
gen q = ae_exp
list, sep(0)

//  Q3.3: 
line  p ae_exp, title(The cumulative distribution curve)xtitle(dépenses ménages (y)) ytitle(F(y));
//  Q3.4: 
line  q p , title(The quantile curve)   xtitle(the percentile (p))  ytitle(The quantile Q(p));

// Q5
c_quantile ae_exp, hsize(hhsize);

// Q6
histogram ae_exp [fweight = hhsize], width(6)
start(0) kdensity kdenopts(width(3) gaussian);
cdensity pcinc , hs(hhsize) band(3) min(0)
max(1000000);
