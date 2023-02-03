#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "abr.h"

        //fonction qui ouvre le fichier de données
FILE* ouvrirFichier(char* nomDuFichier) {
	FILE* fichier = NULL;
	fichier = fopen(nomDuFichier, "r+");
	return fichier;
}

int main(int argc, char **argv) {
    printf("\n");
    
    char donnees[25];
    int testdon = 0;
    char sortie[25];
    int testsor = 0;
    int envers = 0;
    int typetri = 0;

            //recuperation fichier de donnees d'entree
    for(int i=1; i<argc; i++){

        char testf[] = "-f";

        if(strcmp(testf, argv[i])==0){
            strcpy(donnees,argv[i+1]);
            testdon = 1;
            //printf("%s\n", donnees); //affiche dans le terminal l'option choisie
        }
    }

            //recuperation fichier de sortie
    for(int i=1; i<argc; i++){

        char testo[] = "-o";

        if(strcmp(testo, argv[i])==0){
            strcpy(sortie,argv[i+1]);
            testsor = 1;
            //printf("%s\n", sortie); //affiche dans le terminal l'option choisie
        }
    }

            //regarde si on tri en decroissant ou non
    for(int i=1; i<argc; i++){

        char testr[] = "-r";

        if(strcmp(testr, argv[i])==0){
            envers = 1;
            //printf("Reverse\n"); //affiche dans le terminal l'option choisie
        }
    }

            //regarde la méthode a utiliser (abr ou avl ou tableau)
    for(int i=1; i<argc; i++){

        char testavl[] = "--avl";
        char testabr[] = "--abr";
        char testtab[] = "--tab";

        if(strcmp(testavl, argv[i])==0){
            typetri = 0;
        }
        if(strcmp(testabr, argv[i])==0){
            typetri = 1;
        }
        if(strcmp(testtab, argv[i])==0){
            typetri = 2;
        }
    }

//code d'erreur si pas de fichier d'entree ou pas de fichier de sortie
    if(donnees == NULL)
        return 1;

    if(sortie == NULL)
        return 1;

/*      //affiche dans le terminal l'option choisie
    if(typetri == 0)
        printf("AVL\n");
    if(typetri == 1)
        printf("ABR\n");
    if(typetri == 2)
        printf("TAB\n");
*/


	FILE* fichierEntree = ouvrirFichier(donnees);      //ouvre le fichier
    if(fichierEntree == NULL)                           //renvoie le code d'erreur 2 en cas de mauvaise ouverture fu fichier
        return 2;

    if(typetri == 1){                                  //vérifie qu'on utilise la méthode abr (à enlever si on arrive pas a coder les autres méthodes)
        char ligne[25];
        parbre a;
        int flo = 0;
        fgets(ligne, 25, fichierEntree);
        while(!feof(fichierEntree)){                //boucle qui ajoute une a une les valeurs dans un abr
            flo = atoi(ligne);
            a = insertionABR(a, flo);
            fgets(ligne, 25, fichierEntree);
            printf("%d\n", flo);
        }
        if(envers == 0){
            parcoursInfixe(a, fichierEntree);               // parcours infixe pour ecrire les valeurs dans l'ordre croissant (a la suite du fichier d'entree)
        }
        if(envers == 1){
            int nb = 0;
            nb = parcoursDecroissant(a,fichierEntree, nb);      // parcours décroissant pour ecrire les valeurs dans l'ordre décroissant  (a la suite du fichier d'entree)
        }

        fclose(fichierEntree);
        
    }
    
    return 0;
}



