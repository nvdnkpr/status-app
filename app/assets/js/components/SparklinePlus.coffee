{svg, g, path, circle, line, rect, text, div} = React.DOM

SparklinePlus = React.createClass
  render: () ->
    points = @props.points
    if (points.length > 0)
      (svg {
        className: "sparkline-plus"
        style: { height: @props.height }
      }, [
        (g {}, [
          (rect {
            x: 0
            y: 0
            height: @props.height
            width: @state.width
            fill: 'white'
            onMouseMove: @calculateActivePoint
            onMouseLeave: @disableDetail
          })
          (Sparkline {
            points: points
            x: @x
            y: @y
            stroke: "black"
          })
          (circle {
            cx: @x()(points[points.length - 1].x)
            cy: @y()(points[points.length - 1].y)
            r: 2
            fill: "black"
          })
          (text {
            x: @state.width - 45
            y: @y()(points[points.length - 1].y) + 10
            style: {
              fontSize: '1em'
            }
          }, points[points.length - 1].y + @props.unit)

          if @state.showDetail
            HoverDetail({
              detailPoint: @state.detailPoint
              x: @x
              y: @y
              height: @props.height
              unit: @props.unit
            })
        ])
      ])
    else
      (div {}, ["No data"])

  getInitialState: () -> {
    width: 10
    showDetail: false
  }

  calculateActivePoint: (e) ->
    dt = @x().invert(e.clientX - @getDOMNode().getBoundingClientRect().left).getTime()
    lessThan = (point for point in @props.points when point.x < dt)
    biggestLessThan = lessThan[lessThan.length - 1]
    smallestGreaterThan = (point for point in @props.points when point.x > dt)[0]
    nearestPoint =
      if !smallestGreaterThan? || (biggestLessThan? && dt - biggestLessThan.x <= smallestGreaterThan.x)
        biggestLessThan
      else
        smallestGreaterThan
    @setState({
      detailPoint: nearestPoint
      showDetail: true
    })

  disableDetail: () -> @setState({ showDetail: false })

  deriveWidth: () ->
    @setState({
      width: @getDOMNode().offsetWidth
    })

  componentDidMount: () ->
    @deriveWidth()
    window.addEventListener('resize', @deriveWidth)

  componentWillUnmount: () ->
    window.removeEventListener('resize', @deriveWidth)

  x: () ->
    d3.time.scale().range([0, @state.width - 50]).domain(d3.extent(@props.points, (d) -> d.x))

  y: () ->
    d3.scale.linear().range([@sparklineHeight(),12]).domain(d3.extent(@props.points, (d) -> d.y))

  sparklineHeight: () ->
    @props.height - 10

Sparkline = React.createClass
  render: () -> @transferPropsTo(path {
    d : "M#{@props.x()(@props.points[0].x)},#{@props.y()(@props.points[0].y)}" +
      ("L#{@props.x()(p.x)},#{@props.y()(p.y)}" for p in @props.points).join('')
    fill: 'none'
  })

HoverDetail = React.createClass
  render: () -> (g {}, [
    (line {
      x1: @props.x()(@props.detailPoint.x)
      x2: @props.x()(@props.detailPoint.x)
      y1: 0
      y2: @props.height
      stroke: 'black'
    })
    (text {
      x: @props.x()(@props.detailPoint.x) - 3
      y: 0
      style: {
        textAnchor: 'end'
        alignmentBaseline: 'hanging'
      }
    }, d3.time.format('%H:%M')(new Date(@props.detailPoint.x)))
    (text {
      x: @props.x()(@props.detailPoint.x) + 3
      y: 0
      style: {
        textAnchor: 'start'
        alignmentBaseline: 'hanging'
      }
    }, "" + d3.format(' ,')(@props.detailPoint.y) + @props.unit)
  ])

window.SparklinePlus = SparklinePlus