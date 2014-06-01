class Node
  linked: false          # TODO(smurp) probably vestigal
  #links_from_found: true # TODO(smurp) deprecated because links*_found early
  #links_to_found: true   # TODO(smurp) deprecated becasue links*_found early
  showing_links: "none"
  name: null
  s: null                # TODO(smurp) rename Node.s to Node.subject, should be optional
  type: null
  constructor: (@id) ->
    #console.log "new Node(",@id,")"
    @links_from = []
    @links_to = []
    @links_shown = []
  set_name: (@name) ->
  set_subject: (@s) ->
  point: (point) ->
    if point?
      @x = point[0]
      @y = point[1]
    [@x,@y]
  prev_point: (point) ->
    if point?
      @px = point[0]
      @py = point[1]
    [@px,@py]
  pick: () ->
    for edge in this.links_from
      edge.pick()
    for edge in this.links_to
      edge.pick()
    @taxon.update_node(this,{pick:true})
  unpick: () ->
    for edge in this.links_from
      edge.unpick()
    for edge in this.links_to
      edge.unpick()
    @taxon.update_node(this,{pick:false})
  discard: () ->
    # should we unpick first if node.state is picked?
    @taxon.update_node(this,{discard:true})
(exports ? this).Node = Node