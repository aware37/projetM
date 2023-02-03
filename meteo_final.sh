
#!/bin/bash



dete_entree=""
date_sortie=""

fichier_entree=""
fichier_sortie="fichier_sortie"
function Aide {
  echo "Usage: $0 [-t <mode>] [-p <mode>] [-w] [-h] [-m] [-f fichier_sortie] [-o fichier_sortie]"
  echo "  -t <mode>  Affiche les données de température"
  echo "  -p <mode>  Affiche les données de pression atmosphérique"
  echo "  -w  Affiche les données de vent"
  echo "  -h  Affiche les données d'altitude"
  echo "  -m  Affiche les données d'humidité"
  echo "  -f  Spécifie le fichier de données à utiliser"
  echo "  -o  Spécifie le fichier de sortie contenant les données filtrées"
  echo " <mode> :"
  echo "     1 : Produit en sortie les températures (ou pressions) minimales, maximales et moyennes par station dans l’ordre croissant du numéro de station."
  echo "     2 : Produit en sortie les températures (ou pressions) moyennes par date/heure, triées dans l’ordre chronologique. La moyenne se fait sur toutes les stations."
  echo "     3 : Produit en sortie les températures (ou pressions) par date/heure par station. Elles seront triées d’abord par ordre chronologique, puis par ordre croissant de l’identifiant de la station."
  echo "Lieux: $0 [-F] [-G] [-S] [-A] [-O] [-Q]"
  echo "  -F : (F)rance : France métropolitaine + Corse"
  echo "  -G : (G)uyane française"
  echo "  -S : (S)aint-Pierre et Miquelon : ile située à l’Est du Canada"
  echo "  -A : (A)ntilles"
  echo "  -O : (O)céan indien"
  echo "  -Q : antarcti(Q)ue"
  echo "Date: $0 [-d <min> <max>]"
  echo "  -d <min> <max> (d)ates les données de sortie sont dans l’intervalle de dates [<min>..<max>] incluses. Le format des dates est une chaine de type YYYY-MM-DD (année-mois-jour)."
  echo "Tris: $0 [--tab] [--avl] [--abr]"
  echo "  --tab : tri effectué à l’aide d’une structure linéaire (au choix un tableau ou une liste chaînée)"
  echo "  --abr : tri effectué l’aide d’une structure de type ABR"
  echo "  --avl : tri effectué à l’aide d’une structure de type AVL"
  exit 1
}



#Define the filter options
F_filter=false
G_filter=false
S_filter=false
A_filter=false
O_filter=false
Q_filter=false
d_filter=false
t_filter=false
p_filter=false
w_filter=false
m_filter=false
h_filter=false





while getopts "d:FGSAOQt:p:wmhf:o:" option; do
     case $option in
	d) d_filter=true
	   dates=$OPTARG
	   dete_entree=$(echo $OPTARG | cut -d ' ' -f 1)
      	   date_sortie=$(echo $OPTARG | cut -d ' ' -f 2)
	;;
	f) fichier_entree=$OPTARG;;
	o) fichier_entree=$OPTARG;;
	F) F_filter=true;;
	G) G_filter=true;;
	S) S_filter=true;;
	A) A_filter=true;;
	O) O_filter=true;;
	Q) Q_filter=true;;
	t) t_filter=true; arg_t="$OPTARG";;
	p) p_filter=true; arg_p="$OPTARG";;
	w) w_filter=true; arg_w="$OPTARG";;
	m) m_filter=true; arg_m="$OPTARG";;
	h) h_filter=true; arg_h="$OPTARG";;
	H) Aide;;
	\?)
      	echo "Invalid option: -$OPTARG" >&2
      	exit 1
      	;;
    	*)
      	echo "Option -$OPTARG requires an argument." >&2
      	exit 1
      ;;
    esac
done


#Verification que le fichier d'entrer est selectionner
if [ -z "$fichier_entree" ]; then
  echo "Erreur: Fichier entree a definir."
  exit 1
fi


#Verification que au moins une option soit selectionner
if [ "$t_filter" != true ] && [ "$p_filter" != true ] && [ "$w_filter" != true ] && [ "$m_filter" != true ] && [ "$h_filter" != true ]; then
echo "Error: At least one filter option (-w, -m, -t1, -t2, -t3, -p1, -p2, -p3, -h) must be selected."
exit 1
fi



# Fichier temporaire pour stocker les données filtrées
fichier_temporaire=$(mktemp)

# Filtrer les données si l'option -d est sélectionnée
if [ $d_filter = true ]; then
if [ "$dete_entree" != "" ] && [ "$date_sortie" != "" ]; then
  if ! [[ "$dete_entree" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Erreur: Date d'entree dans le mauvais format YYYY-MM-DD format."
    exit 1
  fi

  if ! [[ "$date_sortie" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Erreur: Date de sortie dans le mauvais format YYYY-MM-DD format."
    exit 1
  fi
else
  echo "Erreur: Ecrire les deux date demander"
  exit 1
fi
  awk -F ';T' -v start="$dete_entree" -v end="$date_sortie" '$2 >= start && $2 <= end {print $2}' "$fichier_entree" > "$fichier_temporaire"
else
  awk -F, '{print $0}' "$fichier_entree" > "$fichier_temporaire"
fi



#Filtre en second les données de position si selectionner

fichier_temporaire_filtrer=$(mktemp) 		 # Fichier temporaire, stock donnée du filtrage  
						#Filtre la possition en fonction du code postale, la 15 colonne

if [ $F_filter = true ]; then 
	  awk -F ";" '$15 >= 0 && $15 <= 96000{print $0}' "$fichier_temporaire" > "$fichier_temporaire_filtrer"
	elif [ $G_filter = true ]; then
	  awk -F ";" '$15 >= 97300 && $15 <= 97399 {print $0}' "$fichier_temporaire" > "$fichier_temporaire_filtrer"
	elif [ $S_filter = true ]; then
	  awk -F ";" '$15 >= 97500 && $15 <= 97599 {print $0}' "$fichier_temporaire" > "$fichier_temporaire_filtrer"
	elif [ $A_filter = true ]; then
	  awk -F ";" '$15 >= 97100 && $15 <= 97299 {print $0}' "$fichier_temporaire" > "$fichier_temporaire_filtrer"
	elif [ $O_filter = true ]; then
	  awk -F ";" '$15 >= 97400 && $15 <= 97499 && $15 >= 97600 && $15 <= 97699 {print $0}' "$temp_file" > "$fichier_temporaire_filtrer"
	elif [ $Q_filter = true ]; then
	  awk -F ";"  '$15 >= 98400 && $15 <= 98499 {print $0}' "$fichier_temporaire" > "$fichier_temporaire_filtrer"
	else
	  awk -F ";" '{print $0}' "$fichier_temporaire" > "$fichier_temporaire_filtrer"
fi



# Filtrer les données en fonction des options choisies
if [ $t_filter  = true ]; then
	if [ $arg_t -eq 1 ]; then
       		fichier_temporaire_t1=$(mktemp) 	   # Fichier temporaire, stock donnée du filtrage
		awk -F ";" '{
 		station = $1
  		temp = $11
		if (station in stations) {
		stations[station]["total"] = stations[station]["total"] + temp
		stations[station]["count"] = stations[station]["count"] + 1
		if (temp < stations[station]["min"]) {
		stations[station]["min"] = temp
		}
		if (temp > stations[station]["max"]) {
		stations[station]["max"] = temp
		}
		} else {
		stations[station]["total"] = temp
		stations[station]["count"] = 1
		stations[station]["min"] = temp
		stations[station]["max"] = temp
		}
		} END {
		for (station in stations) {
		moy = stations[station]["total"] / stations[station]["count"]
		print station ";" stations[station]["min"] ";" stations[station]["max"] ";" moy
		}
		}' "$fichier_temporaire_filtrer" |sort -t ";" -k1n > "$fichier_temporaire_t1"


		echo 'set datafile separator ";"
		set term png
		set output "Temerature1.png"
		set style data histograms
		set style histogram errorbars
		set style fill solid 1.00 border -1
		set boxwidth 1.00
		set title "Diagramme de barres derreur"
		set ylabel "Valeur"
		set xlabel "Identifiant de la station"
		plot "'$fichier_temporaire_t1'" using 2:3:4:xticlabels (1) with histograms notitle' > gnu
        gnuplot gnu
        rm gnu

	fi

	if [ $arg_t -eq 2 ]; then
        	fichier_temporaire_t2=$(mktemp) 		#Fichier temporaire, stock donnée du filtrage
		awk -F ";" '{
		date = substr($2,1,25)
		moyenne[date]+=$11
		count[date]++
		} END {
		for (date in moyenne) 
		{
		print date ";" moyenne[date]/count[date]
		}
		}' "$fichier_temporaire_filtrer" |sort -t ";" -k1n > "$fichier_temporaire_t2"

	echo '	set datafile separator ";"
		set term2 png
		set output "temp2.png"
		set timefmt "%Y-%m-%dT%H:%M:%S%z"
		set title "Diagramme de ligne simple"
		set ylabel "Valeur"
		set xlabel "Jour et heure des mesures"
		plot "'$fichier_temporaire_t2'" using 1:2 with lines' > gnu
        gnuplot gnu
        rm gnu
	fi  


	if [ $arg_t -eq 3 ]; then
		fichier_temporaire_t3=$(mktemp) 	# Fichier temporaire, stock donnée du filtrage
		awk -F ";" '{
		date = substr($2,1,25)
		id=$1
		moytemp[id, date]+=$11
		count[id, date]++
		} END {
		for (i in moytemp) {
		split(i, parts, SUBSEP)
		id = parts[1]
		date = parts[2]
		print id ";" date ";" moytemp[id, date]/count[id, date]
		}
		}' "$fichier_temporaire_filtrer" |sort -t ";" -k2,2 -k1,1n > "$fichier_temporaire_t3" 
	echo 'set datafile separator ";"
		set xdata time
		set timefmt "%Y-%m-%dT%H:%M:%S%z"
		set format x "%m/%d"
		set xtics rotate
		set grid
		set key autotitle columnheader
		set title "Diagramme de type multi-lignes"
		set ylabel "Valeurs mesurées"
		set xlabel "Jours"
		plot '$fichier_temporaire_t3' using 2:3 index 0 with lines linetype (2*int(column(-1)/3)+1) title columnhead'> gnu
        gnuplot gnu
        rm gnu
	
	fi
fi



# Filtrer les données en fonction des options choisies
if [ $p_filter  = true ]; then

	if [ $arg_p -eq 1 ]; then    			#Inspiree de ChatGPT 
       		fichier_temporaire_p1=$(mktemp)    	#Fichier temporaire, stock donnée du filtrage

		awk -F ";" '{   
 		station = $1
  		press = $7
		if (station in stations) {
		stations[station]["total"] = stations[station]["total"] + press
		stations[station]["count"] = stations[station]["count"] + 1
		if (press < stations[station]["min"]) {
		stations[station]["min"] = press
		}
		if (press > stations[station]["max"]) {
		stations[station]["max"] = press
		}
		} else {
		stations[station]["total"] = press
		stations[station]["count"] = 1
		stations[station]["min"] = press
		stations[station]["max"] = press
		}
		} END {
		for (station in stations) {
		moy = stations[station]["total"] / stations[station]["count"]
		print station ";" stations[station]["min"] ";" stations[station]["max"] ";" moy
		}
		}' "$fichier_temporaire_filtrer" |sort -t ";" -k1n > "$fichier_temporaire_p1"

	echo 'set datafile separator ";"
		set press1 png
		set output "press1.png"
		set style data histograms
		set style histogram errorbars
		set style fill solid 1.00 border -1
		set boxwidth 1.00
		set title "Diagramme de barres derreur"
		set ylabel "Valeur"
		set xlabel "Identifiant de la station"
		plot "'$fichier_temporaire_p1'" using 2:3:4:xticlabels (1) with histograms notitle' > gnu
        gnuplot gnu
        rm gnu
	fi

	if [ $arg_p -eq 2 ]; then
        	fichier_temporaire_p2=$(mktemp) # Fichier temporaire, stock donnée du filtrage
		awk -F ";" '{
		date = substr($2,1,25)
		moyenne[date] += $7
		count[date]++
		} END {
		for (date in moyenne) 
		{
		print date ";" moyenne[date]/count[date]
		}
		}' "$fichier_temporaire_filtrer" |sort -t ";" -k1n > "$fichier_temporaire_p2"
		echo '	set datafile separator ";"
		set press2 png
		set output "press2.png"
		set timefmt "%Y-%m-%dT%H:%M:%S%z"
		set title "Diagramme de ligne simple"
		set ylabel "Valeur"
		set xlabel "Jour et heure des mesures"
		plot "'$fichier_temporaire_p2'" using 1:2 with lines' > gnu
        gnuplot gnu
        rm gnu
fi  


	if [ $arg_p -eq 3 ]; then
		fichier_temporaire_p3=$(mktemp) # Fichier temporaire, stock donnée du filtrage
		awk -F ";" '{
		date = substr($2,1,25)
		id=$1
		moypress[id, date]+=$11
		count[id, date]++
		} END {
		for (i in moypress) {
		split(i, parts, SUBSEP)
		id = parts[1]
		date = parts[2]
		print id ";" date ";" moypress[id, date]/count[id, date]
		}
		}' "$fichier_temporaire_filtrer" |sort -t ";" -k2,2 -k1,1n > "$fichier_temporaire_p3" 

	echo 'set datafile separator ";"
		set press3 png
		set output "press3.png"
		set xdata time
		set timefmt "%Y-%m-%dT%H:%M:%S%z"
		set format x "%m/%d"
		set xtics rotate
		set grid
		set key autotitle columnheader
		set title "Diagramme de type multi-lignes"
		set ylabel "Valeurs mesurées"
		set xlabel "Jours"
		plot '$fichier_temporaire_p3' using 2:3 index 0 with lines linetype (2*int(column(-1)/3)+1) title columnhead'> gnu
        gnuplot gnu
        rm gnu
	fi
fi



#Filtre les donner en fonction du vent (option -w)
	if [ $w_filter  = true ]; then
		fichier_temporaire_w=$(mktemp)
		awk -F ";" '{
		id=$1
		x_wind[id]+=$4
		y_wind[id]+=$5
		coord[id]=$10
		count[id]++
		} END {
		for (id in x_wind) {
		avg_x_wind = x_wind[id]/count[id]
		avg_y_wind = y_wind[id]/count[id]
		avg_wind_speed = sqrt(avg_x_wind^2 + avg_y_wind^2)
		avg_wind_orientation = atan2(avg_y_wind, avg_x_wind) * 180/3.14159265358979323846
		print id ";" avg_wind_speed ";" avg_wind_orientation ";" coord[id]
		}
		}' "$fichier_temporaire_filtrer" | sort -t ";" -k1n > "$fichier_temporaire_w"

	echo '  reset session
		set terminal png
		set output "humidite.png"
		set datafile separator ";,"
		set style data lines
		set xlabel "Latitude"
		set ylabel "Longitude"
		set dgrid3d 30,20,10
		set pm3d map
		set palette rgb 10,20,30
		splot "'$fichier_temporaire_w'" using 4:3:2'> gnu
        gnuplot gnu
        rm gnu


	fi



#Filtre les donner en fonction de l'humidite (option -m)
	if [ $m_filter  = true ]; then
		fichier_temporaire_m=$(mktemp)
		awk -F ";" '{
		id=$1
		coord[id]=$10
		if (humidite[id] == "" || $6 > humidite[id]) 
		{
		humidite[id]=$6
		}
		} END {
		for (id in humidite) {
		print id ";" humidite[id] ";" coord[id]
		}
		}' "$fichier_temporaire_filtrer" |sort -t ";" -k1,1nr > "$fichier_temporaire_m"

	echo '  reset session
		set terminal png
		set output "humidite.png"
		set datafile separator ";,"
		set style data lines
		set xlabel "Latitude"
		set ylabel "Longitude"
		set dgrid3d 30,20,10
		set pm3d map
		set palette rgb 10,20,30
		splot "'$fichier_temporaire_m'" using 4:3:2' > gnu
        gnuplot gnu
        rm gnu
	

	fi



#Filtre les donner en fonction de l'altitude (option -h)
	if [ $h_filter  = true ]; then
		# Stocker les informations pour chaque station
		fichier_temporaire_h=$(mktemp)
		awk -F ";" '{
		id=$1
		altitude[id]=$14
		coord[id]=$10
		} END {
		for (id in altitude) {
		print id ";" altitude[id] ";" coord[id]
		}
		}' "$fichier_temporaire_filtrer" |sort -t ";" -k1,1nr > "$fichier_temporaire_h"
		
	echo '  reset session
	set terminal png
        set output "altitude.png"
        set datafile separator ";,"
        set style data lines
        set xlabel "Latitude"
        set ylabel "Longitude"
        set dgrid3d 30,20,10
        set pm3d map
        set palette rgb 10,20,30
        splot "'$fichier_temporaire_h.csv'" using 4:3:2'> gnu
        gnuplot gnu
        rm gnu
		
		
	fi




rm $fichier_temporaire_w 
rm /tmp/tmp.*
