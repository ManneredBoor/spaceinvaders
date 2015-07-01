module.exports =

	intersect: (a_x, a_y, a_w, a_h, b_x, b_y, b_w, b_h) ->
		return a_x < b_x + b_w and b_x < a_x + a_w and a_y < b_y + b_h and b_y < a_y + a_h;
