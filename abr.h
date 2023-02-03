#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef struct arbreBinaire{                  //structure d'arbre binaire classique
    int value;
    struct arbreBinaire *fg;
    struct arbreBinaire *fd;
}arbreBinaire, *parbre;






int estVide(parbre a)                     //verifie si un arbre est vide
{
    if(a == NULL)
        return 1;
    else
        return 0;
}

parbre creerArbre(int e)                  //fonction de création de noeud classique
{
    parbre a;
    a = malloc(sizeof(*a));

    a->value = e;
    a->fg = NULL;
    a->fd = NULL;

    return a;
}

void traiter(parbre a, FILE* sortie)             //c'est ctte fonction qui devrait écrire chaque valeurs de l'arbre dans le fichier de sortie (pas sur quelle fonctionne)
{
    if(estVide(a)){
        fprintf(stderr, "erreur arbre vide");
        exit(4);
    }
    char val[25];
    sprintf(val, "%d\n", a->value);
    printf("[%s]", val);
    fputs(val, sortie);
}


void parcoursInfixe(parbre a,FILE* sortie)            //fonction de parcours classique on renseigne seulement le nom du fichier de sortie
{
    if(!estVide(a)){
        parcoursInfixe(a->fg, sortie);
        traiter(a, sortie);
        parcoursInfixe(a->fd, sortie);
    }
}

int parcoursDecroissant(parbre a,FILE* sortie, int nb)      //fonction de parcours classique on renseigne seulement le nom du fichier de sortie
{
    if(a != NULL){
        nb = parcoursDecroissant(a->fd,sortie, nb);
        traiter(a,sortie);
        nb++;
        nb = parcoursDecroissant(a->fg,sortie, nb);
    }
    return nb;
}

parbre insertionABR(parbre a, int e)                     //fonction classique d'insertion dans l'abr
{
    if(estVide(a))
        return creerArbre(e);
    else if(e < a->value)
        a->fg = insertionABR(a->fg, e);
    else if(e >= a->value)
        a->fd = insertionABR(a->fd, e);
    return a;
}


