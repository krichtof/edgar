$ ->
  $start = $("#start_tour")

  tour = new Tour(
    onStart: -> $start.addClass "disabled", true
    onEnd: -> $start.removeClass "disabled", true
    backdrop: true
#    debug: true
  )

  tour.addSteps [
      title: "Bienvenue !"
      content: "Ceci est un guide de présentation de l’application." +
        "<br>(Vous pouvez utiliser les flèches gauche et droite de votre clavier pour passer les étapes.)"
      orphan: true
    ,
      
      element: ".leftpanel"
      placement: "right"
      title: "Voyons d’abord le menu principal"
      content: "A votre gauche, le menu principal, à partir duquel vous pourrez gérer vos contacts, organiser vos tâches..."
      fixed: true
    ,

      element: "#accounts-tab"
      placement: "right"
      title: "Compte"
      content: "Cliquez ici pour paramétrer votre compte : <br> - renseigner vos données personnelles <br> - ajouter la photo de votre profil  <br> - créer vos projets artistiques"
      fixed: true
      
#campaigns-nav

    ,
      element: "#search-nav"
      placement: "right"
      title: "Recherche"
      content: "Atteignez en un clin d’œil à une personne ou une structure."
      fixed: true
    ,
      element: "#plusmenu-trigger"
      placement: "left"
      title: "Le bouton +"
      content: "Le bouton plus vous permet à tout moment de créer une nouvelle personne, structure ou tâche"
      fixed: true 
    ,

      element: "#recent-nav"
      placement: "right"
      title: "Dernièrement"
      content: "Ici une liste des fiches consultées récemment."
      fixed: true
      onShown: (tour) -> clickerShow()
#      onNext: (tour) -> clickerHide()
    ,
      element: "#opportunities-nav"
      placement: "right"
      title: "Contrats"
      content: "Bientôt ici la liste de vos contrats pour vos futures dates de spectacle ..."
      fixed: true
    ,
      element: ".footer"
      placement: "top"
      title: "En bas à gauche ... Quelques liens pour"
      content: "- se déconnecter"+
        "<br>- recommencer ce tour"+
        "<br>- voir le guide en ligne de Merci Edgar"+
        "<br>- nous faire des suggestions et signaler des erreurs"
      fixed: true
    ,
      element: "#dash-stats"
      placement: "top"
      title: "Les Stats"
      content: "Easy is better, right? Easy like Bootstrap."
    ,
      title: "Ce tour est terminé"
      content: "Un tour sera disponible pour la plupart des pages."
      orphan: true
      
    ]

  tour.start()

  $('<div class="alert alert-warning"><button class="close" data-dismiss="alert">&times;</button>You ended the demo tour. <a href="#" class="start">Restart the demo tour.</a></div>').prependTo(".content").alert() if tour.ended()

  $(document).on "click", ".start", (e) ->
    e.preventDefault()
    return if $(this).hasClass "disabled"
    tour.restart()
    $(".alert").alert "close"

  $("html").smoothScroll()