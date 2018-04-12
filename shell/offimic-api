#!/bin/sh 

oc_handle_get() {
	# on attrape le parametre de la fonction
	line="$1" 

	# le verble http (= le premier mot de la requete)
	route="$(echo "$line" |sed -e 's/^GET  *//')"

	echo "Route: $route"

	# table de routage 
	case "$route" in 
		/history) # faire des trucs pour history
			cat history.csv >> input
			# TODO: rediriger ça vers le client
			;;

		/count/*) # faire des trucs pour count
			value="$(echo "$route" |sed -e 's|/count/||')"
			timestamp="$(date --rfc-3339=seconds)"

			echo "$timestamp, $value" >> history.csv
			;;
	esac
}

oc_handle_post() {
	>&2 echo "Warning: NOT YET IMPLEMENTED"
}

oc_handle_request() {
	# on attrape le parametre de la fonction
	read line
	# le verble http (= le premier mot de la requete)
	verb="$(echo "$line" |awk '{print $1;}')"

	echo "Cat pid = $pid"
	echo "Verb: $verb"
	case "$verb" in 
		GET)
			oc_handle_get "$line"
			;;
		POST)
			oc_handle_post "$line"
			;;
	esac
	echo "Closing pipe..."
	exec 3>&-
	> input
}

# écouter sur le port 80 	
# prendre une requete
# lire la requete 'GET ... '

# GET /history
# => oc_history
# GET /count/:value
# => oc_count
oc_server() {
	port="$1" 

	while true ; do 
		exec 3<> input

		>&3 cat input &
		pid="$!"

		echo "Ready for next client !"
		nc -l -q 1 -p "$port" <&3 -c "oc_handle_request"
		#"$pid"
	done
}

oc_server "$1"

