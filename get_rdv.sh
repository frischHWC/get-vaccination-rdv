#/bin/bash

base_url="https://www.doctolib.fr"
ref_visit_motive_ids_1=6970
ref_visit_motive_ids_2=7005
specialty_id=5494
city=$1

url_parameters="ref_visit_motive_ids[]=${ref_visit_motive_ids_1}&ref_visit_motive_ids[]=${ref_visit_motive_ids_2}&speciality_id=${specialty_id}&search_result_format=json&force_max_limit=2"
city_url_parameters="ref_visit_motive_ids[]=${ref_visit_motive_ids_1}&ref_visit_motive_ids[]=${ref_visit_motive_ids_2}&force_max_limit=2"

city_answer=$( curl -s -L -H "Accept: application/json" -H "User-Agent: GiveMeARdv" ${base_url}/vaccination-covid-19/${city}?${city_url_parameters} )
cities_formatted=$(echo $city_answer | sed 's/[àéè@€âôöäùüûêë]//g') 

cities_ids=$( echo $cities_formatted | jq .data.doctors[].id )

rdv_dispo="false"

for i in $cities_ids
do
    answer=$(curl -s -L -H "Accept: application/json" -H "User-Agent: GiveMeARdv" ${base_url}/search_results/${i}.json?${url_parameters} )
    avaibilities=$( echo ${answer} | jq .total )
    if [ ${avaibilities} != "0" ]
    then
        rdv_link=$( echo $cities_formatted | jq ".data.doctors[] | select(.id == $i) | .link" | sed 's/"//g' )
        rdv_city=$( echo $cities_formatted | jq ".data.doctors[] | select(.id == $i) | .city" | sed 's/"//g' )
        echo "RDV disponible à : ${rdv_city} , URL : ${base_url}${rdv_link}"
        rdv_dispo="true"
    fi
done

if [ $rdv_dispo == "true" ]
then
    echo ""
    echo " Des RDVs sont dispo, regardez : ${base_url}/vaccination-covid-19/${city}?${city_url_parameters} "
    echo ""
fi
