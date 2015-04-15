#!/bin/bash

elencoDeiFile=`ls $2`

if [ $? -gt 0 ]
then
	echo "Sorgente non disponibile"
	exit 1
fi

if [ `ls $2 | wc -l` -eq 0 ]
then
	echo "Sorgente vuota"
	exit 2
fi

elencoDelleDirectory=`ls $3`
if [ $? -gt 0 ]
then
	echo "Cartella di destinazione non disponibile"
	exit 3
fi

if [ $1 == 'Completo' ]
then
	dataBackup=0
else
	if [ $1 == 'Incrementale' ]
	then
		elencoDelleDirectory=`ls $3`
		dataBackup=0
		for i in $elencoDelleDirectory
		do
			dataIndice=`stat -c %Y $3/$i`
			if [ $dataIndice -gt $dataBackup ]
			then
				dataBackup=$dataIndice
			fi
		done
			if [ $dataBackup -eq 0 ]
				then
					echo "Eseguire un backup"
					exit 6
				fi
		else
			if [ $1 == 'Differenziale' ]
			then
				dataBackup=0
				for i in $elencoDelleDirectory
				do 
					if [ ${i:13:8} == 'Completo' ]
					then
						dataIndice=`stat -c %Y $3/$i`
						if [ $dataIndice -gt $dataBackup ]
						then
							dataBackup=$dataIndice
						fi
					fi
				done
				if [ $dataBackup -eq 0 ]
				then
					echo "Eseguire un backup Completo"
					exit 5
				fi
			else
				echo "Backup non riconosciuto"
				exit 7
			fi
		fi
fi
fileDaCopiare=`ls $2`
cartelleBackup=`date +%Y%m%d%H%M`

t=0
s=0
e=0
mkdir $3/${cartelleBackup}_$1
for i in $fileDaCopiare
do
	dataFile=`stat -c %Y $2/$i`
	if [ $dataFile -gt $dataBackup ]
	then
		t=$((total+1))
		cp $2/$i $3/${cartelleBackup}_$1
		if [ $? -gt 0 ]
		then
			echo "Impossibile eseguire il backup di $i" >&2
			e=$((e+1))
		else
			echo "Backup di: $i effettuato"
			s=$((s+1))
		fi
	fi
done
if [ $e -eq 0 ]
	then
		exit 0
	else
		exit 4
	fi
fi