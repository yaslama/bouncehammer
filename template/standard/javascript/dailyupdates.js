/* $Id: dailyupdates.js,v 1.1 2010/08/28 17:13:39 ak Exp $ */
function timecmp(a,b){ return a.machinetime - b.machinetime; }
function plot(dudata,dustat,opt)
{
	// Semi-Log Graph
	var canvas = document.getElementById('jx_duplot');
	var canv2d = null;

	if( canvas.getContext )
	{
		canv2d = canvas.getContext('2d');
		dudata.sort(timecmp);
		canv2d.clearRect( 0, 0, canvas.width, canvas.height );

		var offset = { x: 48, y: 20 };
		var ylimit = 1000;	// Auto detect or 3rd argument of this function
		var lgbase = 10;
		var maxofd = Math.max(
				stat.max.estimated,
				Math.max(
					stat.max.failed,
					Math.max(
						stat.max.skipped,
						Math.max( stat.max.inserted, stat.max.updated )
					)
				) );
		var axisof = {	x: { min: offset.x, max: canvas.width - offset.x },
				y: { min: offset.y, max: canvas.height - offset.y } };
		var scales = {	x: axisof.x.max / ( dudata.length + 1 ),
				y: axisof.y.max / ( Math.log(maxofd) / Math.log(lgbase) + 1 ) };

		var column = [ 'estimated', 'failed', 'skipped', 'updated', 'inserted' ];
		var colors = { 
			estimated: { 
				line: '#e5e4e6',	// Shiraumenezu
				text: '#2b2b2b',	// Rou-iro
				mean: '#595857'		// Sumi
			},
			skipped: { 
				line: '#f8b500',	// Yamabuki-iro
				text: '#ee7800',	// Daidai-iro
				mean: '#583822'		// Kurocha
			},
			inserted: {
				line: '#b8d200',	// Kimidori
				text: '#007b43',	// Tokiwa-iro
				mean: '#00552e'		// Fukamidori
			},
			updated: {
				line: '#5383c3',	// Usugunjou
				text: '#19448e',	// Rurikon
				mean: '#1c305c'		// Tomekon
			},
			failed: {
				line: '#d3381c',	// Hi-iro
				text: '#c9171e',	// Kokihi
				mean: '#640125'		// Ebi-iro
			}
		};
		var ascale = { start: 1, endby: Math.ceil( Math.log(maxofd) / Math.log(lgbase) ) + 1 };
		var lgraph = ( opt && opt.semilog ) ? 1 : 0;

		if( lgraph == 0 )
		{
			scales.y = axisof.y.max / ( maxofd * 1.1 );
			ascale.start = Math.pow( 10, Math.floor( Math.log(maxofd) / Math.log(10) ) );
			if( ascale.start > ( maxofd / 2 ) ) ascale.start = Math.floor(ascale.start / 2);
			ascale.endby = ( Math.ceil( maxofd / ascale.start ) + 0 ) * ascale.start;
		}


		// Plot(Common settings)
		canv2d.strokeStyle = '#dcdddd';	// Shiro-nezu
		canv2d.fillStyle = '#383c3c';	// Youkan-iro
		canv2d.font = 'normal 9px Verdana';

		// Auxiliary scale
		canv2d.lineWidth = 0.5;
		canv2d.beginPath();
		canv2d.BaseLine = 'center';
		canv2d.textAlign = 'right';

		for( g = ascale.start; g < ascale.endby; g += ascale.start )
		{
			// Plot auxiliary scale lines
			var y = axisof.y.max - g * scales.y;
			canv2d.moveTo( axisof.x.min, y );
			canv2d.lineTo( axisof.x.max + offset.x - 1, y );
			canv2d.fillText( 
				( lgraph ? Math.pow(10,g) : g ), axisof.x.min - 5, y + 4 );
			canv2d.stroke();
		}

		// Axis
		canv2d.strokeStyle = "#727171";	// Nibi-iro
		canv2d.lineWidth = 1;
		canv2d.beginPath();
		canv2d.moveTo( axisof.x.min, axisof.y.max );
		canv2d.lineTo( axisof.x.max + offset.x, axisof.y.max );
		canv2d.moveTo( axisof.x.min, axisof.y.max );
		canv2d.lineTo( axisof.x.min, axisof.y.min - offset.y );
		canv2d.stroke();

		canv2d.lineWidth = 3;
		canv2d.font = 'bold 9px Verdana';
		canv2d.BaseLine = 'bottom';
		canv2d.textAlign = 'center';
		canv2d.lineJoin = 'round';
		canv2d.lineCap = 'round';	// End of the line


		var p = { x: 0, y: 0 };
		var r = 1.2;
		var y = 0;
		var thisdata = 0;
		var maximumv = 0;
		var thismean = 0;
		var thelabel = "";
		var xlabeled = 0;
		var xlabelpo = 0;
		var barwidth = Math.E/dudata.length * 128; if( barwidth > 32 ) barwidth = 32;
		var sqheight = 0;
		var stepping = dudata.length > 29 ? 2 : 1;

		for( e = 0; e < column.length; e++ )
		{
			canv2d.strokeStyle = eval( 'colors.' + column[e] + '.line' );
			canv2d.fillStyle = eval( 'colors.' + column[e] + '.text' );
			canv2d.beginPath();
			maximumv = eval( 'stat.max.' + column[e] );
			thismean = eval( 'stat.mean.' + column[e] );

			if( opt && eval( 'opt.v' + column[e] ) == 1 )
			{
				for( i = 0, j = dudata.length; i < j; i++ )
				{
					thisdata = eval( 'dudata[i].' + column[e] );
					p.x = i * scales.x + offset.x + barwidth/2;

					if( lgraph )
					{
						p.y = axisof.y.max - ( Math.log(thisdata) / Math.log(lgbase) * scales.y );
						if( p.y == Infinity ) p.y = axisof.y.max;
						if( column[e] == 'estimated' ) sqheight = Math.log(thisdata) / Math.log(lgbase) * scales.y;
					}
					else
					{
						p.y = axisof.y.max - thisdata * scales.y;
						if( column[e] == 'estimated' ) sqheight = thisdata * scales.y;
					}

					if( column[e] == 'estimated' )
					{
						// Bar plot
						canv2d.fillStyle = colors.estimated.line;
						canv2d.strokeStyle = colors.estimated.text; 
						canv2d.fillRect( p.x - barwidth/2 + 1, p.y, barwidth - 1, sqheight - 1 );
					}
					else
					{
						canv2d.arc( p.x, p.y, r, 0, Math.PI * 2, false );
						canv2d.moveTo( p.x, p.y );
					}

					if( xlabeled == 0 && ( i == 0 || i + 1 == j || i % stepping == 0 ) )
					{
						// X-Label: Date
						if( dudata[i].xlabel.length > 4 && i > 0 )
						{
							thelabel = dudata[i].xlabel.slice(5);
						}
						else
						{
							thelabel = dudata[i].xlabel;
						}

						xlabelpo = i == 0 ? p.x - 12 : p.x;
						canv2d.save();
						canv2d.font = 'normal 8px Verdana';
						canv2d.fillStyle = '#383c3c';	// Youkan-iro
						canv2d.fillText( thelabel, xlabelpo, axisof.y.max + offset.y * 0.7 );
						canv2d.restore();
					}

					if( thisdata > 0 && ( thisdata == maximumv || i + 1 == j ) )
					{
						// Maximum
						if( i == 0 || i + 1 == j ) p.x += 16;
						if( column[e] == 'estimated' ) canv2d.fillStyle = colors.estimated.text;
						canv2d.fillText( thisdata, p.x, p.y - p.y * 0.1 );
					}
				}
				canv2d.stroke();
				xlabeled = 1;
			}

			// Plot mean of each datum
			if( opt && eval( 'opt.m' + column[e] ) == 1 )
			{
				if( lgraph )
				{
					y = axisof.y.max - ( Math.log(thismean) / Math.log(lgbase) * scales.y );
					if( y == Infinity ) y = axisof.y.max;
				}
				else
				{
					y = axisof.y.max - thismean * scales.y;
				}

				canv2d.globalCompositeOperation = 'destination-over';
				canv2d.beginPath();
				canv2d.save();

				canv2d.lineWidth = 1.5;
				canv2d.strokeStyle = eval( 'colors.' + column[e] + '.mean' );
				canv2d.textAlign = 'right';

				canv2d.moveTo( axisof.x.min, y );
				canv2d.lineTo( axisof.x.max + offset.x - 1, y );
				canv2d.fillText( thismean, axisof.x.min - 5, y + 4 );

				canv2d.stroke();
				canv2d.restore();
				canv2d.globalCompositeOperation = 'source-over';
			}

		}
	}
}

