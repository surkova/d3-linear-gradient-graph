$ () ->
	'use strict';
	# input data
	timestamps = ['02:11:00','02:11:02',
								'02:11:04','02:11:06',
								'02:11:08','02:11:10',
								'02:11:12','02:11:14',
								'02:11:16','02:11:18']
	events = [10,15,134,23,56,33,16,34,56,23]
	travelTimes = [2,13,35,8,30,1,40,15,22,4]
	dataset = []
	
	# populating array with timestamps, events and travel times
	dataset = ([timestamps[index], events[index], travelTimes[index]] for ts, index in timestamps)

	# graph canvas
	w = 890
	h = 500
	padding = 40
	svg = d3.select('#graph').append('svg:svg').attr('width', w).attr('height', h)

	# axes
	format = d3.time.format('%H:%M:%S')
	beginning = format.parse(timestamps[0])
	end = format.parse(timestamps[9])
	x = d3.time.scale().domain([beginning, end]).range([padding, w-padding/2])
	y = d3.scale.linear().domain([0, d3.max(events)+padding/2]).range([h-padding, padding/2])
	color = d3.scale.linear().domain([d3.min(travelTimes), d3.max(travelTimes)]).range(['#C3FF68', '#FF4040'])
	
	# let's draw our axes
	drawAxes = () ->
		xAxis = d3.svg.axis().scale(x).orient('bottom').ticks(d3.time.seconds, 2)
		yAxis = d3.svg.axis().scale(y).orient('left')

		svg.append('svg:g')
				.attr('class', 'axis')
				.attr("transform", "translate(0," + (h - padding) + ")")
				.call(xAxis)
		svg.append('svg:g')
				.attr('class', 'axis')
				.attr("transform", "translate(" + padding + ",0)")
				.call(yAxis)

	# let's draw the actual graph
	drawGraph = () ->
		# line and area generators
		line = d3.svg.line()
				.x((d) -> x(format.parse(d[0])) + 1)
				.y((d) -> y(d[1]))
				.interpolate('monotone')
		
		area = d3.svg.area()
				.x((d) -> x(format.parse(d[0])) + 1)
				.y0(h - padding - 1)
				.y1((d) -> y(d[1]))
				.interpolate('monotone')

		# defining color stops for our gradient
		defs = svg.append('svg:defs')
		offset = -100/(dataset.length-1)

		defs.append('svg:linearGradient')
				.attr('id', 'gradient')
				.selectAll('.colorStop')
				.data(dataset)
				.enter()
				.append('stop')
				.attr('class', 'colorStop')
				.attr('offset', 
					(d) -> 
						offset += 100/(dataset.length-1)
						offset + '%')
				.style('stop-color', (d) -> color(d[2]))

		# let's append our line and area
		svg.append('svg:path')
				.attr('class', 'path')
				.attr('d', line(dataset))

		svg.append('svg:path')
				.attr('class', 'area')
				.attr('d', area(dataset))

	drawAxes()
	drawGraph()