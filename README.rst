PACWar
======

Projet IHM RICM5 utilisant le modèle de conception/programmation PAC.

.. image:: http://i.imgur.com/HqA1M.png
    :align: center

Installation
------------

Ubuntu :

::

    sudo apt-get install tcl8.5 tk8.5 libtk-img


Utilisation
-----------

Pour lancer le jeu utiliser le script main `app.tcl`:

::

  cd src; wish ./app.tcl introspac

ou avec make:

::

  make


Joueur 1:

 - <Left> : Se déplacer vers la gacuhe
 - <Right> : Se déplacer vers la droite
 - <Top> : Se déplacer vers le haut
 - <Bottom> : Se déplacer vers le bas
 - <Space> : Tirer

Joueur 2:
 - <q> : Se déplacer vers la gacuhe
 - <d> : Se déplacer vers la droite
 - <z> : Se déplacer vers le haut
 - <s> : Se déplacer vers le bas
 - <Space> : Tirer
