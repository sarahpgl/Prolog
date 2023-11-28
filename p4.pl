:- use_module(library(clpfd)).


% Définition du prédicat qui lance le jeu
jeu :- 
    grille_vide(Grille), % On crée une grille vide
    affiche_grille(Grille), % On affiche la grille
    tour(humain,Grille). % C'est le tour de l'humain

% Définition du prédicat qui gère le tour d'un joueur
tour(Joueur,Grille) :-
    gagne(Joueur,Grille), % On vérifie si le joueur a gagné
    !, % On coupe pour éviter de chercher d'autres solutions
    write(Joueur), write(' a gagné !'), nl. % On affiche le message de victoire


tour(Joueur,Grille) :-
    write('Tour de '), write(Joueur), nl, % On affiche le tour du joueur
    choix_colonne(Joueur,Grille,Colonne), % On choisit une colonne
    ajoute_pion(Joueur,Grille,Colonne,NouvelleGrille), % On ajoute le pion du joueur dans la colonne choisie
    affiche_grille(NouvelleGrille), % On affiche la nouvelle grille
    change_joueur(Joueur,AutreJoueur), % On change de joueur
    tour(AutreJoueur,NouvelleGrille). % On continue le jeu avec l'autre joueur

% Définition du prédicat qui choisit une colonne selon le joueur
choix_colonne(humain,Grille,Colonne) :-
    repeat, % On répète jusqu'à avoir une colonne valide
    write('Choisissez une colonne (1-7) : '), % On demande à l'humain de choisir une colonne
    read(Colonne), % On lit la colonne entrée par l'humain
    colonne_valide(Colonne), % On vérifie que la colonne est valide
    colonne_non_pleine(Grille,Colonne), % On vérifie que la colonne n'est pas pleine
    !. % On coupe pour éviter de chercher d'autres solutions
choix_colonne(ia,Grille,Colonne) :-
    repeat, % On répète jusqu'à avoir une colonne valide
    random(1,8,Colonne), % On génère un nombre aléatoire entre 1 et 7 pour la colonne
    colonne_non_pleine(Grille,Colonne), % On vérifie que la colonne n'est pas pleine
    !. % On coupe pour éviter de chercher d'autres solutions

% Définition du prédicat qui vérifie si une colonne est valide
colonne_valide(Colonne) :-
    Colonne >= 1, % La colonne doit être supérieure ou égale à 1
    Colonne =< 7. % La colonne doit être inférieure ou égale à 7

% Définition du prédicat qui vérifie si une colonne n'est pas pleine
colonne_non_pleine(Grille,Colonne) :-
    nth1(Colonne,Grille,Col), % On récupère la colonne de la grille
    member(vide,Col). % On vérifie qu'il y a au moins une case vide dans la colonne

% Définition du prédicat qui ajoute un pion dans une colonne
ajoute_pion(Joueur,Grille,Colonne,NouvelleGrille) :-
    nth1(Colonne,Grille,Col), % On récupère la colonne de la grille
    ajoute_pion_colonne(Joueur,Col,NouvelleColonne), % On ajoute le pion du joueur dans la colonne
    remplacer(Grille,Colonne,NouvelleColonne,NouvelleGrille). % On remplace la colonne de la grille par la nouvelle colonne

% Définition du prédicat qui ajoute un pion dans une colonne
ajoute_pion_colonne(Joueur,[vide|Reste],[Joueur|Reste]) :- % Si la première case est vide, on la remplace par le pion du joueur
    !. % On coupe pour éviter de chercher d'autres solutions
ajoute_pion_colonne(Joueur,[X|Reste],[X|NouveauReste]) :- % Sinon, on garde la première case et on continue avec le reste de la colonne
    ajoute_pion_colonne(Joueur,Reste,NouveauReste).

% Définition du prédicat qui remplace un élément d'une liste par un autre
remplacer([_|Reste],1,X,[X|Reste]) :- % Si l'indice est 1, on remplace le premier élément par X
    !. % On coupe pour éviter de chercher d'autres solutions
remplacer([Tete|Reste],Indice,X,[Tete|NouveauReste]) :- % Sinon, on garde la tête de la liste et on continue avec le reste
    Indice > 1, % L'indice doit être supérieur à 1
    NouvelIndice is Indice - 1, % On décrémente l'indice
    remplacer(Reste,NouvelIndice,X,NouveauReste). % On appelle récursivement le prédicat

% Définition du prédicat qui change de joueur
change_joueur(humain,ia). % Si le joueur est humain, l'autre joueur est ia
change_joueur(ia,humain). % Si le joueur est ia, l'autre joueur est humain

% Définition du prédicat qui crée une grille vide
grille_vide([[vide,vide,vide,vide,vide,vide],
             [vide,vide,vide,vide,vide,vide],
             [vide,vide,vide,vide,vide,vide],
             [vide,vide,vide,vide,vide,vide],
             [vide,vide,vide,vide,vide,vide],
             [vide,vide,vide,vide,vide,vide],
             [vide,vide,vide,vide,vide,vide]]).

% Définition du prédicat qui affiche une grille
affiche_grille(Grille) :-
    transpose(Grille,GrilleTransposee), % On transpose la grille pour afficher les colonnes comme des lignes
    reverse(GrilleTransposee,GrilleInversee), % On inverse la grille pour afficher la case en bas à gauche en premier
    affiche_lignes(GrilleInversee), % On affiche les lignes de la grille
    nl. % On saute une ligne

% Définition du prédicat qui affiche les lignes d'une grille
affiche_lignes([]) :- % Si la grille est vide, on ne fait rien
    !. % On coupe pour éviter de chercher d'autres solutions
affiche_lignes([Ligne|Reste]) :- % Sinon, on affiche la première ligne et on continue avec le reste
    affiche_separateur, % On affiche un séparateur horizontal
    affiche_ligne(Ligne), % On affiche la première ligne
    nl, % On saute une ligne
    affiche_lignes(Reste). % On appelle récursivement le prédicat
affiche_lignes(_) :- % Quand on a fini d'afficher les lignes, on affiche un dernier séparateur
    affiche_separateur.

% Définition du prédicat qui affiche un séparateur horizontal
affiche_separateur :-
    write('\033[1m'), % On active le mode gras
    write('┌'), % On affiche le coin supérieur gauche
    write('──┬──┬──┬──┬──┬──┬─'), % On répète 6 fois le trait horizontal et le séparateur vertical
    write('─┐'), % On affiche le trait horizontal et le coin supérieur droit
    write('\033[0m'), % On réinitialise le mode normal
    nl. % On saute une ligne

% Définition du prédicat qui affiche une ligne d'une grille
affiche_ligne([]) :- % Si la ligne est vide, on ne fait rien
    !. % On coupe pour éviter de chercher d'autres solutions
affiche_ligne([Case|Reste]) :- % Sinon, on affiche la première case et on continue avec le reste
    write('\033[1m'), % On active le mode gras
    write('│'), % On affiche le séparateur vertical
    write('\033[0m'), % On réinitialise le mode normal
    affiche_case(Case), % On affiche la première case
    write(' '), % On écrit un espace
    affiche_ligne(Reste). % On appelle récursivement le prédicat



% Définition du prédicat qui affiche une case d'une grille
affiche_case(vide) :- % Si la case est vide, on affiche un point
    write('.').
affiche_case(humain) :- % Si la case est occupée par l'humain, on affiche un X rouge
    write('\033[31m'), % On change la couleur en rouge
    write('X'), % On affiche le X
    write('\033[0m'). % On réinitialise la couleur
affiche_case(ia) :- % Si la case est occupée par l'ia, on affiche un O jaune
    write('\033[33m'), % On change la couleur en jaune
    write('O'), % On affiche le O
    write('\033[0m'). % On réinitialise la couleur


% Définition du prédicat qui vérifie si un joueur a gagné
gagne(Joueur,Grille) :-
    aligne(Joueur,Grille,4). % On vérifie si le joueur a aligné 4 pions

% Définition du prédicat qui vérifie si un joueur a aligné un nombre de pions
aligne(Joueur,Grille,NbPions) :-
    horizontal(Joueur,Grille,NbPions). % On vérifie si le joueur a aligné NbPions pions horizontalement
aligne(Joueur,Grille,NbPions) :-
    vertical(Joueur,Grille,NbPions). % On vérifie si le joueur a aligné NbPions pions verticalement
aligne(Joueur,Grille,NbPions) :-
    diagonal(Joueur,Grille,NbPions). % On vérifie si le joueur a aligné NbPions pions diagonalement

% Définition du prédicat qui vérifie si un joueur a aligné un nombre de pions horizontalement
horizontal(Joueur,Grille,NbPions) :-
    member(Ligne,Grille), % On choisit une ligne de la grille
    horizontal_ligne(Joueur,Ligne,NbPions). % On vérifie si le joueur a aligné NbPions pions dans la ligne

% Définition du prédicat qui vérifie si un joueur a aligné un nombre de pions dans une ligne
horizontal_ligne(Joueur,Ligne,NbPions) :-
    append(_,Suite,Ligne), % On choisit une sous-liste de la ligne
    append(Pions,_,Suite), % On choisit une sous-liste de la sous-liste
    length(Pions,NbPions), % On vérifie que la sous-liste a la longueur voulue
    tous_egaux(Joueur,Pions). % On vérifie que la sous-liste ne contient que des pions du joueur

% Définition du prédicat qui vérifie si une liste ne contient que des éléments égaux à un élément donné
tous_egaux(_,[]). % Une liste vide est considérée comme contenant que des éléments égaux
tous_egaux(X,[X|Reste]) :- % Si la tête de la liste est égale à X, on continue avec le reste
    tous_egaux(X,Reste).

% Définition du prédicat qui vérifie si un joueur a aligné un nombre de pions verticalement
vertical(Joueur,Grille,NbPions) :-
    transpose(Grille,GrilleTransposee), % On transpose la grille pour avoir les colonnes comme des lignes
    horizontal(Joueur,GrilleTransposee,NbPions). % On vérifie si le joueur a aligné NbPions pions horizontalement dans la grille transposée

% Définition du prédicat qui vérifie si un joueur a aligné un nombre de pions diagonalement
diagonal(Joueur,Grille,NbPions) :-
    diagonales(Grille,Diagonales), % On récupère les diagonales de la grille
    member(Diagonale,Diagonales), % On choisit une diagonale
    horizontal_ligne(Joueur,Diagonale,NbPions). % On vérifie si le joueur a aligné NbPions pions dans la diagonale

% Définition du prédicat qui récupère les diagonales d'une grille
diagonales(Grille,Diagonales) :-
    diagonales_gauche(Grille,DiagonalesGauche), % On récupère les diagonales allant de gauche à droite
    reverse(Grille,GrilleInversee), % On inverse la grille
    diagonales_gauche(GrilleInversee,DiagonalesDroite), % On récupère les diagonales allant de droite à gauche
    append(DiagonalesGauche,DiagonalesDroite,Diagonales). % On concatène les deux listes de diagonales

% Définition du prédicat qui récupère les diagonales allant de gauche à droite d'une grille
diagonales_gauche(Grille,Diagonales) :-
    decaler(Grille,GrilleDecalee), % On décale la grille vers le bas
    transpose(GrilleDecalee,GrilleTransposee), % On transpose la grille décalée
    diagonales_lignes(GrilleTransposee,Diagonales). % On récupère les diagonales des lignes de la grille transposée

% Définition du prédicat qui décale une grille vers le bas
decaler([],[]). % Une grille vide est décalée en une grille vide
decaler([Ligne|Reste],[LigneDecalee|ResteDecale]) :- % Sinon, on décale la première ligne et on continue avec le reste
    decaler_ligne(Ligne,LigneDecalee), % On décale la première ligne
    decaler(Reste,ResteDecale). % On appelle récursivement le prédicat

% Définition du prédicat qui décale une ligne vers le bas
decaler_ligne(Ligne,LigneDecalee) :-
    append([vide],Ligne,LigneTemp), % On ajoute une case vide au début de la ligne
    append(LigneDecalee,[_],LigneTemp). % On enlève la dernière case de la ligne

% Définition du prédicat qui récupère les diagonales des lignes d'une grille
diagonales_lignes([],[]). % Une grille vide n'a pas de diagonales
diagonales_lignes([Ligne|Reste],Diagonales) :-
    diagonales_ligne(Ligne,DiagonalesLigne), % On récupère les diagonales de la première ligne
    diagonales_lignes(Reste,DiagonalesReste), % On appelle récursivement le prédicat avec le reste de la grille
    append(DiagonalesLigne,DiagonalesReste,Diagonales). % On concatène les deux listes de diagonales

% Définition du prédicat qui récupère les diagonales d'une ligne
diagonales_ligne([],[]). % Une ligne vide n'a pas de diagonales
diagonales_ligne([X|Reste],[[X]|DiagonalesReste]) :- % Sinon, on crée une diagonale avec la première case et on continue avec le reste
    diagonales_ligne(Reste,DiagonalesTemp), % On appelle récursivement le prédicat avec le reste de la ligne
    ajouter_tete(Reste,DiagonalesTemp,DiagonalesReste). % On ajoute la tête du reste de la ligne à chaque diagonale du reste

% Définition du prédicat qui ajoute un élément à la tête de chaque liste d'une liste de listes
ajouter_tete(_,[],[]). % Si la liste de listes est vide, on ne fait rien
ajouter_tete(X,[Ligne|Reste],[[X|Ligne]|ResteAjoute]) :- % Sinon, on ajoute X à la tête de la première liste et on continue avec le reste
    ajouter_tete(X,Reste,ResteAjoute). % On appelle récursivement le prédicat

% Définition du prédicat qui vérifie si la grille est pleine
grille_pleine(Grille) :-
    forall(member(Ligne,Grille), % Pour chaque ligne de la grille
           forall(member(Case,Ligne), % Pour chaque case de la ligne
                  nonvar(Case))). % La case n'est pas une variable
