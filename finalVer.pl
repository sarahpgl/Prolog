:- use_module(library(clpfd)).


% Définition du prédicat qui lance le jeu
jeu :- 
    grille_vide(Grille), % On crée une grille vide
    affiche_grille(Grille), % On affiche la grille
    %On randomise le premier joueur
    random(0,2,Random), % On génère un nombre aléatoire entre 0 et 1
    (Random == 0 -> tour(ia,Grille) ; tour(humain,Grille)). % On lance le jeu avec le premier joueur aléatoire

% Définition du prédicat qui gère le tour d'un joueur
tour(Joueur,Grille) :-
    gagne(ia,Grille), % On vérifie si le joueur a gagné
    !, % On coupe pour éviter de chercher d'autres solutions
    write(ia), write(' a gagné !'), nl. % On affiche le message de victoire

% Définition du prédicat qui gère le tour d'un joueur
tour(Joueur,Grille) :-
    gagne(humain,Grille), % On vérifie si le joueur a gagné
    !, % On coupe pour éviter de chercher d'autres solutions
    write(humain), write(' a gagné !'), nl. % On affiche le message de victoire

tour(Joueur,Grille) :-
    grille_pleine(Grille), % On vérifie si la grille est pleine
    !, % On coupe pour éviter de chercher d'autres solutions
    write('Match nul!') ,nl. % On affiche le message de match nul

    tour(Joueur,Grille) :-
        (   gagne(ia,Grille) % On vérifie si le joueur a gagné
        ->  write('IA a gagné.'), nl % Si le joueur a gagné, on affiche un message
        ;   write('Tour de '), write(Joueur), nl, % Sinon, on continue le jeu
            choix_colonne(Joueur,Grille,Colonne), % On choisit une colonne
            ajoute_pion(Joueur,Grille,Colonne,NouvelleGrille), % On ajoute le pion du joueur dans la colonne choisie
            affiche_grille(NouvelleGrille), % On affiche la nouvelle grille
            change_joueur(Joueur,AutreJoueur), % On change de joueur
            tour(AutreJoueur,NouvelleGrille) % On continue le jeu avec l'autre joueur
        ).
    

% Définition du prédicat qui donne une matrice de poids pour chaque case
matrice_poids([
    [3,4,5,7,5,4,3],
    [4,6,8,10,8,6,4],
    [5,8,11,13,11,8,5],
    [5,8,11,13,11,8,5],
    [4,6,8,10,8,6,4],
    [3,4,5,7,5,4,3]
]).


% Définition du prédicat qui choisit une colonne selon le joueur
choix_colonne(humain,Grille,Colonne) :-
    repeat, % On répète jusqu'à avoir une colonne valide
    write('Choisissez une colonne (1-7) : '), % On demande à l'humain de choisir une colonne
    read(Colonne), % On lit la colonne entrée par l'humain
    colonne_valide(Colonne), % On vérifie que la colonne est valide
    colonne_non_pleine(Grille,Colonne), % On vérifie que la colonne n'est pas pleine
    !. % On coupe pour éviter de chercher d'autres solutions

% Définition du prédicat qui choisit la colonne où l'IA va jouer
choix_colonne(ia, Grille, Colonne) :-
    meilleur_coup(Grille, Colonne, Val), % On appelle le prédicat qui renvoie le meilleur coup selon l'algorithme minmax
    write('L''IA joue dans la colonne '), write(Colonne), write(' avec une valeur de '), write(Val), nl. % On affiche le coup choisi par l'IA


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
    nth1(Colonne,Grille,ColonneGrille), % On extrait la colonne de la grille
    ligne(Grille,Colonne,Ligne), % On trouve la ligne où le pion va tomber
    remplacer(ColonneGrille,Ligne,Joueur,NouvelleColonne), % On remplace la case vide par le pion du joueur
    remplacer(Grille,Colonne,NouvelleColonne,NouvelleGrille). % On remplace la colonne par la nouvelle colonne

/* Plus besoin grace au nouveau predicat ligne !!!!!!!!!!!!!!!
% Définition du prédicat qui ajoute un pion dans une colonne
ajoute_pion_colonne(Joueur,[vide|Reste],[Joueur|Reste]) :- % Si la première case est vide, on la remplace par le pion du joueur
    !. % On coupe pour éviter de chercher d'autres solutions
ajoute_pion_colonne(Joueur,[X|Reste],[X|NouveauReste]) :- % Sinon, on garde la première case et on continue avec le reste de la colonne
    ajoute_pion_colonne(Joueur,Reste,NouveauReste).
*/

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

% Définition du prédicat qui affiche une grille avec les numéros de colonnes
affiche_grille(Grille) :-
    transpose(Grille, GrilleTransposee), % On transpose la grille pour afficher les colonnes comme des lignes
    reverse(GrilleTransposee, GrilleInversee), % On inverse la grille pour afficher la case en bas à gauche en premier
    affiche_lignes(GrilleInversee), % On affiche les lignes de la grille
    affiche_numeros_colonnes, % On affiche les numéros de colonnes
    nl. % On saute une ligne

% Définition du prédicat qui affiche les numéros de colonnes
affiche_numeros_colonnes :-
    write('1 2 3 4 5 6 7'), nl. % On affiche les numéros de colonnes sous le plateau

% Définition du prédicat qui affiche les lignes d'une grille
affiche_lignes([]) :- % Si la grille est vide, on ne fait rien
    !. % On coupe pour éviter de chercher d'autres solutions
affiche_lignes([Ligne|Reste]) :- % Sinon, on affiche la première ligne et on continue avec le reste
    affiche_ligne(Ligne), % On affiche la première ligne
    nl, % On saute une ligne
    affiche_lignes(Reste). % On appelle récursivement le prédicat

% Définition du prédicat qui affiche une ligne d'une grille
affiche_ligne([]) :- % Si la ligne est vide, on ne fait rien
    !. % On coupe pour éviter de chercher d'autres solutions
affiche_ligne([Case|Reste]) :- % Sinon, on affiche la première case et on continue avec le reste
    affiche_case(Case), % On affiche la première case
    write(' '), % On écrit un espace
    affiche_ligne(Reste). % On appelle récursivement le prédicat


% Définition du prédicat qui affiche une case d'une grille avec couleur
affiche_case(vide) :- % Si la case est vide, on affiche un point
    write('\e[94m.\e[0m').
affiche_case(humain) :- % Si la case est occupée par l'humain, on affiche un X en bleu
    write('\e[93mX\e[0m').
affiche_case(ia) :- % Si la case est occupée par l'ia, on affiche un O en rouge
    write('\e[91mO\e[0m').



% Définition du prédicat qui vérifie si un joueur a gagné
gagne(Joueur,Grille) :-
    aligne(Joueur,Grille,4). % On vérifie si le joueur a aligné 4 pions
grille_pleine([]).

% Définition du prédicat qui vérifie si la grille est pleine
grille_pleine([Col|Grille]) :-
    not(member(vide,Col)),
    grille_pleine(Grille).

% Définition du prédicat qui vérifie si un joueur a aligné un nombre de pions
aligne(Joueur,Grille,NbPions) :-
    horizontal(Joueur,Grille,NbPions). % On vérifie si le joueur a aligné NbPions pions horizontalement
aligne(Joueur,Grille,NbPions) :-
    vertical(Joueur,Grille,NbPions). % On vérifie si le joueur a aligné NbPions pions verticalement
aligne(Joueur,Grille,NbPions) :-
    diagonal(Joueur,Grille). % On vérifie si le joueur a aligné NbPions pions diagonalement

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

diagonal(Jouer,Grille):-
    append(_,[C1,C2,C3,C4|_],Grille), % 4 colonnes consecutifs
    append(P1,[Jouer|_],C1), % qui a un piéce du Jouer
    append(P2,[Jouer|_],C2),
    append(P3,[Jouer|_],C3),
    append(P4,[Jouer|_],C4),
    length(P1,L1), length(P2,L2), length(P3,L3), length(P4,L4),% on obtien la ligne
    (L2 is L1+1, L3 is L2+1, L4 is L3+1;  %... diagonale gauche /
    L2 is L1-1, L3 is L2-1, L4 is L3-1). %... diagonale droite \
    

%%%

% Définition du prédicat qui calcule le poids d'un coup
poids(Grille,Poids,Colonne,PoidsCoup) :-
    ligne(Grille,Colonne,Ligne), % On trouve la ligne où le pion va tomber
    nth1(Ligne,Poids,LignePoids), % On extrait la ligne de poids correspondante
    nth1(Colonne,LignePoids,PoidsCoup). % On extrait le poids du coup

% Définition du prédicat qui trouve la ligne où le pion va tomber
ligne(Grille,Colonne,Ligne) :-
    nth1(Colonne,Grille,ColonneGrille), % On extrait la colonne de la grille
    ligne2(ColonneGrille,1,Ligne). % On cherche la ligne à partir de la première

ligne2([Case|_],Ligne,Ligne) :-
    Case == vide, % On vérifie si la case est vide
    !. % On coupe pour éviter de chercher d'autres solutions
ligne2([_|Reste],LigneCourante,Ligne) :-
    LigneSuivante is LigneCourante + 1, % On incrémente la ligne
    ligne2(Reste,LigneSuivante,Ligne). % On continue avec le reste de la colonne


% Définition du prédicat qui vérifie si un élément appartient à une liste
element(Elem,Liste) :-
    member(Elem,Liste). % On utilise le prédicat prédéfini member/2


    %%%%


% Définition du prédicat qui choisit le meilleur coup selon l'algorithme minmax
meilleur_coup(Grille, Colonne, Val) :-
    coups_possibles(Grille, Liste_coups), % On récupère la liste des coups possibles
    prof_max(Prof_max), % On récupère la profondeur maximale
    best(Liste_coups, Grille, Prof_max, Colonne, Val). % On cherche le meilleur coup parmi la liste

% Définition du prédicat qui renvoie la profondeur maximale
prof_max(2). % On peut modifier la profondeur maximale ici 
/*
         /\
        /  \
       /    \
      /______\  Pour modifier la profondeur ça se passe ici (au délà de 3 il est bien lent ce lait)
         | |
         | |
         | |
         | |
         | |
         |_|
*/


% Définition du prédicat qui compare les coups possibles et renvoie le meilleur
best([Coup], Grille, Prof, Coup, Val) :- % S'il n'y a qu'un coup possible, on l'évalue
    ajoute_pion(ia, Grille, Coup, NouvelleGrille), % On joue le coup de l'IA
    minmax(NouvelleGrille, Prof, humain, Val), % On évalue le coup selon le point de vue de l'humain
    !. % On coupe pour éviter de chercher d'autres solutions
best([Coup1|Liste_coups], Grille, Prof, MeilleurCoup, MeilleurVal) :- % S'il y a plusieurs coups possibles, on les compare
    ajoute_pion(ia, Grille, Coup1, NouvelleGrille1), % On joue le premier coup de l'IA
    minmax(NouvelleGrille1, Prof, humain, Val1), % On évalue le premier coup selon le point de vue de l'humain
    best(Liste_coups, Grille, Prof, Coup2, Val2), % On cherche le meilleur coup parmi le reste de la liste
    %write('Compare '), write(Coup1), write(' '), write(Val1), write(' et '), write(Coup2), write(' '), write(Val2), nl, % On affiche les deux coups et leurs valeurs
    better(Coup1, Val1, Coup2, Val2, MeilleurCoup, MeilleurVal). % On compare les deux coups et on garde le meilleur

% Définition du prédicat qui implémente l'algorithme minmax
minmax(Grille, Prof, Joueur, Val) :-
    (partie_finie(Grille) ; Prof = 0), % Si la partie est finie ou si la profondeur est nulle, on évalue le plateau
    eval_plateau(Grille, Val),
    !. % On coupe pour éviter de chercher d'autres solutions
minmax(Grille, Prof, Joueur, Val) :-
    coups_possibles(Grille, Liste_coups), % Sinon, on récupère la liste des coups possibles
    Prof1 is Prof - 1, % On décrémente la profondeur
    change_joueur(Joueur, AutreJoueur), % On change de joueur
    eval_liste(Liste_coups, Grille, Prof1, Adversaire, Liste_vals), % On évalue la liste des coups
    (Joueur = ia -> max_liste(Liste_vals, Val) ; min_liste(Liste_vals, Val)). % On choisit le maximum ou le minimum selon le joueur

% Définition du prédicat qui évalue la liste des coups possibles
eval_liste([], _, _, _, []). % Si la liste est vide, on renvoie une liste vide
eval_liste([Coup|Liste_coups], Grille, Prof, Joueur, [Val|Liste_vals]) :- % Sinon, on évalue le premier coup et on continue avec le reste de la liste
    ajoute_pion(Joueur, Grille, Coup, NouvelleGrille), % On joue le coup
    minmax(NouvelleGrille, Prof, Joueur, Val), % On évalue le coup selon l'algorithme minmax
    eval_liste(Liste_coups, Grille, Prof, Joueur, Liste_vals). % On évalue le reste de la liste

% Définition du prédicat qui renvoie le maximum d'une liste
max_liste([X], X). % Si la liste n'a qu'un élément, c'est le maximum
max_liste([X|L], Max) :- % Sinon, on compare le premier élément avec le maximum du reste de la liste
    max_liste(L, Max1),
    (X > Max1 -> Max = X ; Max = Max1).

% Définition du prédicat qui renvoie le minimum d'une liste
min_liste([X], X). % Si la liste n'a qu'un élément, c'est le minimum
min_liste([X|L], Min) :- % Sinon, on compare le premier élément avec le minimum du reste de la liste
    min_liste(L, Min1),
    (X < Min1 -> Min = X ; Min = Min1).

% Définition du prédicat qui compare deux coups et renvoie le meilleur
better(Coup1, Val1, Coup2, Val2, Coup1, Val1) :- % Le premier coup est meilleur si sa valeur est supérieure à celle du deuxième
    Val1 > Val2,
    !. % On coupe pour éviter de chercher d'autres solutions
better(Coup1, Val1, Coup2, Val2, Coup2, Val2). % Sinon, le deuxième coup est meilleur

% Définition du prédicat qui vérifie si la partie est nulle
partie_nulle(Grille) :-
    coups_possibles(Grille, Liste_coups), % On récupère la liste des coups possibles
    Liste_coups == []. % On vérifie si la liste est vide

% Définition du prédicat qui récupère les coups possibles dans une grille
coups_possibles(Grille, Coups) :-
    length(Grille, NbColonnes), % On récupère le nombre de colonnes dans la grille
    findall(Colonne, (between(1, NbColonnes, Colonne), \+ colonne_pleine(Colonne, Grille)), Coups). % On génère les colonnes non pleines

% Définition du prédicat qui vérifie si une colonne est pleine dans une grille
colonne_pleine(Colonne, Grille) :-
    nth1(Colonne, Grille, Col), % On récupère la colonne correspondante
    \+ member(vide, Col). % On vérifie si la colonne ne contient pas de case vide

% Définition du prédicat qui vérifie si la partie est finie
partie_finie(Grille) :-
    gagne(ia, Grille) ; % On vérifie si l'IA a gagné
    gagne(humain, Grille) ; % On vérifie si l'humain a gagné
    partie_nulle(Grille). % On vérifie si la partie est nulle

    % Définition du prédicat qui évalue la valeur d'un plateau
eval_plateau(Grille, Val) :-
    gagne(ia, Grille), % On vérifie si l'IA a gagné
    Val is 10000, % Si oui, on attribue une valeur très grande
    %write('Détection d un coup offrant victoire à l IA'), nl, % On affiche un message
    !. % On coupe pour éviter de chercher d'autres solutions
eval_plateau(Grille, Val) :-
    gagne(humain, Grille), % On vérifie si l'humain a gagné
    Val is -10000, % Si oui, on attribue une valeur très petite
    %write('Détection d un coup offrant victoire à l humain'), nl, % On affiche un message
    !. % On coupe pour éviter de chercher d'autres solutions
eval_plateau(Grille, Val) :-
    partie_nulle(Grille), % On vérifie si la partie est nulle
    Val is 0, % Si oui, on attribue une valeur nulle
    !. % On coupe pour éviter de chercher d'autres solutions

    %Fonction d'évaluation !!!!!!
eval_plateau(Grille, Val) :-
    eval_plateau_poids(Grille, Poids), % On évalue le plateau en utilisant eval_plateau_poids
    totalSumscore(Grille, ia, ScoreIa), % On compte le nombre de pions alignés de l'IA sur la grille
    totalSumscore(Grille, humain, ScoreH), % On compte le nombre de pions alignés de l'humain sur la grille
    Val is Poids*4 + ScoreIa*5 - ScoreH*10. % On calcule la différence entre les deux nombres et on ajoute le poids
    % On peut ajuster les coef pour avoir une IA plus agressive ou plus défensive

%%%

eval_plateau_poids(Grille, Val) :-
    matrice_poids(Poids),
    transpose(Poids, PoidsTranspose),
    multiplier_matrices(PoidsTranspose, Grille, Val).

% Prédicat pour la multiplication de deux matrices
multiplier_matrices([], [], 0).
multiplier_matrices([L1|R1], [L2|R2], Total) :-
    multiplier_vecteurs(L1, L2, Result),
    multiplier_matrices(R1, R2, Reste),
    Total is Result + Reste.


% Prédicat pour la multiplication de deux vecteurs
multiplier_vecteurs([], [], 0).
multiplier_vecteurs([T1|R1], [T2|R2], Result) :-
    valeur(T2, Val),
    Prod is T1 * Val,
    multiplier_vecteurs(R1, R2, Reste),
    Result is Prod + Reste.

% Définition des valeurs
valeur(ia, 2).  %On met un poids de 2 pour favoriser les coups avantageux
valeur(vide, 0).
valeur(humain, -1).






%%
% totalSumscore(Grille, Joueur, TotalSumscore) is true if TotalSumscore is the sum of sumscoreligne and sumscorecolonne
totalSumscore(Grille, Joueur, TotalSumscore) :-
    sumScoreLigne(Grille, Joueur, ScoreLigne),
    sumScoreColonne(Grille, Joueur, ScoreColonne),
    TotalSumscore is ScoreLigne + ScoreColonne.


% sumScoreLigne(Grille, Joueur, ScoreTotal) is true if ScoreTotal is the sum of the ScoreLigne for each line in the grid
sumScoreLigne(Grille, Joueur, ScoreTotal) :-
    sumScoreLigneHelper(Grille, Joueur, 1, ScoreTotal).

% Helper predicate for sumScoreLigne
sumScoreLigneHelper(_, _, 7, 0). % Base case: when all lines have been traversed, the sum is 0
sumScoreLigneHelper(Grille, Joueur, NumLigne, ScoreTotal) :-
    compte_ligne(Grille, Joueur, NumLigne, ScoreLigne), % Calculate the ScoreLigne for the current line
    NextNumLigne is NumLigne + 1, % Increment the line number
    sumScoreLigneHelper(Grille, Joueur, NextNumLigne, RemainingScoreTotal), % Recursively traverse the next line
    ScoreTotal is ScoreLigne + RemainingScoreTotal. % Sum the ScoreLigne with the remaining score total


% sumScoreColonne(Grille, Joueur, ScoreTotal) is true if ScoreTotal is the sum of the ScoreLigne for each line in the grid
sumScoreColonne(Grille, Joueur, ScoreTotal) :-
    sumScoreColonneHelper(Grille, Joueur, 1, ScoreTotal).

% Helper predicate for sumScoreColonne
sumScoreColonneHelper(_, _, 8, 0). % Base case: when all lines have been traversed, the sum is 0
sumScoreColonneHelper(Grille, Joueur, NumColonne, ScoreTotal) :-
    compte_colonne(Grille, Joueur, NumColonne, ScoreColonne), % Calculate the ScoreLigne for the current line
    NextNumColonne is NumColonne + 1, % Increment the line number
    sumScoreColonneHelper(Grille, Joueur, NextNumColonne, RemainingScoreTotal), % Recursively traverse the next line
    ScoreTotal is ScoreColonne + RemainingScoreTotal. % Sum the ScoreLigne with the remaining score total

    

% compte_ligne(Grille, Joueur, NumLigne, Score) est vrai si Score est le nombre de pions alignés
% sur la même ligne pour le joueur Joueur dans la grille Grille à la ligne NumLigne
compte_ligne(Grille, Joueur, NumLigne, Score) :-

    transpose(Grille, GrilleTransposee),

    % on récupère la ligne correspondante dans la grille
    nth1(NumLigne, GrilleTransposee, Ligne),
    % on compte le nombre de pions consécutifs du joueur dans la ligne
    compte_consecutifs(Ligne, Joueur, Score).

% compte_colonne(Grille, Joueur, NumColonne, Score) est vrai si Score est le nombre de pions alignés
% sur la même colonne pour le joueur Joueur dans la grille Grille à la colonne NumColonne
compte_colonne(Grille, Joueur, NumColonne, Score) :-
    % on extrait la colonne correspondante dans la grille
    nth1(NumColonne, Grille, Colonne),
    % on compte le nombre de pions consécutifs du joueur dans la colonne
    compte_consecutifs(Colonne, Joueur, Score).

% extrait_colonne(Grille, NumColonne, Colonne) est vrai si Colonne est la liste des éléments
% à la colonne NumColonne dans la grille Grille
extrait_colonne([], _, []).
extrait_colonne([Ligne|Reste], NumColonne, [Element|Suite]) :-
    % on récupère l'élément à la colonne NumColonne dans la ligne
    nth1(NumColonne, Ligne, Element),
    % on récursive sur le reste de la grille
    extrait_colonne(Reste, NumColonne, Suite).


% compte_consecutifs(Liste, Valeur, Score) est vrai si Score est le nombre maximum
% d'éléments consécutifs égaux à Valeur dans la liste Liste
compte_consecutifs(Liste, Valeur, Score) :-
    % on initialise un compteur à 0
    compte_consecutifs(Liste, Valeur, 0, Score).

% compte_consecutifs(Liste, Valeur, Compteur, Score) est vrai si Score est le nombre maximum
% d'éléments consécutifs égaux à Valeur dans la liste Liste, en tenant compte du compteur courant
compte_consecutifs([], _, Compteur, Compteur). % on renvoie le compteur quand la liste est vide
compte_consecutifs([Valeur|Reste], Valeur, Compteur, Score) :-
    % on incrémente le compteur si l'élément est égal à la valeur
    NouveauCompteur is Compteur + 1,
    compte_consecutifs(Reste, Valeur, NouveauCompteur, Score).
compte_consecutifs([Autre|Reste], Valeur, Compteur, Score) :-
    % on réinitialise le compteur si l'élément est différent de la valeur
    Autre \= Valeur,
    compte_consecutifs(Reste, Valeur, 0, Score),
    % on garde le score maximum entre le compteur et le score précédent
    Score =:= max(Compteur, Score).
compte_consecutifs([_|Reste], Valeur, Compteur, Score) :- % on traite le cas où le premier élément est différent de la valeur
    compte_consecutifs(Reste, Valeur, Compteur, Score).