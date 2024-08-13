
Usage: fgfs [ option ... ]

General Options:
   --help, -h                   Show the most relevant command line options
   --launcher                   Use GUI launcher
   --verbose, -v                Show all command line options when combined
                                with --help or -h
   --version                    Display the current FlightGear version
   --fg-root=path               Specify the root data path
   --fg-scenery=path            Specify the scenery path(s);
                                Defaults to $FG_ROOT/Scenery
   --fg-aircraft=path           Specify additional aircraft directory path(s)
                                (alternatively, you can use --aircraft-dir to
                                target a specific aircraft in a given
                                directory)
   --download-dir=path          Base directory to use for aircraft and scenery
                                downloads (the TerraSync scenery directory may
                                be specifically set with --terrasync-dir)
   --language=code              Select the language for this session
   --load-tape=path             Load recording of earlier flightgear session
   --restore-defaults           Reset all user settings to their defaults
                                (rendering options etc)
   --disable-save-on-exit       Don't save preferences upon program exit
   --enable-save-on-exit        Allow saving preferences at program exit
   --browser-app=path           Specify path to your web browser
   --prop:[type:]name=value     Set property <name> to <value>. <type> can be
                                one of string, double, float, long, int, or
                                bool.
   --config=path                Load additional properties from path
   --units-feet                 Use feet for distances
   --units-meters               Use meters for distances
   --console                    Display console (Windows specific)
   --json-report                Print a report in JSON format on the standard
                                output, giving information such as the
                                FlightGear version, $FG_ROOT, $FG_HOME,
                                aircraft and scenery paths, etc.

Features:
   --disable-panel              Disable instrument panel
   --enable-panel               Enable instrument panel
   --disable-hud                Disable Heads Up Display (HUD)
   --enable-hud                 Enable Heads Up Display (HUD)
   --disable-anti-alias-hud     Disable anti-aliased HUD
   --enable-anti-alias-hud      Enable anti-aliased HUD
   --disable-hud-3d             Disable 3D HUD
   --enable-hud-3d              Enable 3D HUD
   --hud-tris                   Hud displays number of triangles rendered
   --hud-culled                 Hud displays percentage of triangles culled
   --disable-random-objects     Exclude random scenery objects
                                (buildings, etc.)
   --enable-random-objects      Include random scenery objects
                                (buildings, etc.)
   --disable-random-vegetation  Exclude random vegetation objects
   --enable-random-vegetation   Include random vegetation objects
   --disable-random-buildings   Exclude random buildings objects
   --enable-random-buildings    Include random buildings objects
   --disable-ai-models          Deprecated option (disable internal AI
                                subsystem)
   --enable-ai-models           Enable AI subsystem (required for multi-player,
                                AI traffic and many other animations)
   --disable-ai-traffic         Disable artificial traffic.
   --enable-ai-traffic          Enable artificial traffic.
   --ai-scenario=scenario       Add and enable a new scenario. Multiple options
                                are allowed.
   --disable-freeze             Start in a running state
   --enable-freeze              Start in a frozen state
   --disable-fuel-freeze        Fuel is consumed normally
   --enable-fuel-freeze         Fuel tank quantity forced to remain constant
   --disable-clock-freeze       Clock advances normally
   --enable-clock-freeze        Do not advance clock

   --failure={pitot|static|vacuum|electrical}
                                Fail the pitot, static, vacuum, or electrical
                                system (repeat the option for multiple system
                                failures).

Audio Options:
   --show-sound-devices         Show a list of available audio device
   --sound-device               Explicitly specify the audio device to use
   --disable-sound              Disable sound effects
   --enable-sound               Enable sound effects

Rendering Options:
   --enable-rembrandt           Enable Rembrandt rendering
   --disable-rembrandt          Disable Rembrandt rendering
   --disable-splash-screen      Disable splash screen
   --enable-splash-screen       Enable splash screen
   --disable-mouse-pointer      Disable extra mouse pointer
   --enable-mouse-pointer       Enable extra mouse pointer
                                (i.e. for full screen Voodoo based cards)
   --max-fps=Hz                 Maximum frame rate in Hz.
   --bpp=depth                  Specify the bits per pixel
   --fog-disable                Disable fog/haze
   --fog-fastest                Enable fastest fog/haze
   --fog-nicest                 Enable nicest fog/haze
   --disable-enhanced-lighting  Disable enhanced runway lighting
   --enable-enhanced-lighting   Enable enhanced runway lighting

   --disable-distance-attenuation
                                Disable runway light distance attenuation

   --enable-distance-attenuation
                                Enable runway light distance attenuation
   --disable-horizon-effect     Disable celestial body growth illusion near the
                                horizon
   --enable-horizon-effect      Enable celestial body growth illusion near the
                                horizon

   --disable-specular-highlight
                                Disable specular reflections on textured
                                objects
   --enable-specular-highlight  Enable specular reflections on textured objects
   --fov=degrees                Specify field of view angle

   --aspect-ratio-multiplier=factor
                                Specify a multiplier for the aspect ratio.
   --disable-fullscreen         Disable fullscreen mode
   --enable-fullscreen          Enable fullscreen mode
   --shading-flat               Enable flat shading
   --shading-smooth             Enable smooth shading
   --materials-file=file        Specify the materials file used to render the
                                scenery (default:
                                Materials/regions/materials.xml)
   --texture-filtering=value    Anisotropic Texture Filtering: values should be
                                1 (default),2,4,8 or 16
   --disable-wireframe          Disable wireframe drawing mode
   --enable-wireframe           Enable wireframe drawing mode
   --geometry=WxH               Specify window geometry (640x480, etc)
   --view-offset=value          Specify the default forward view direction as
                                an offset from straight ahead. Allowable values
                                are LEFT, RIGHT, CENTER, or a specific number
                                in degrees

Aircraft:
   --aircraft=name              Select an aircraft profile as defined by a top
                                level <name>-set.xml
   --aircraft-dir=path          Specify the exact directory to use for the
                                aircraft (normally not required, but may be
                                useful). Interpreted relatively to the current
                                directory. Causes the <path-cache> from
                                autosave_X_Y.xml, as well as --fg-aircraft and
                                the FG_AIRCRAFT environment variable to be
                                bypassed.
   --show-aircraft              Print a list of the currently available
                                aircraft types

   --min-status={alpha,beta,early-production,production}
                                Allows you to define a minimum status level
                                (=development status) for all listed aircraft
   --fdm=name                   Select the core flight dynamics model
                                Can be one of jsb, larcsim, yasim, magic,
                                balloon, ada, external, or null
   --aero=name                  Select aircraft aerodynamics model to load
   --model-hz=n                 Run the FDM this rate (iterations per second)
   --speed=n                    Run the FDM 'n' times faster than real time
   --trim                       Trim the model
                                (only with fdm=jsbsim)
   --notrim                     Do NOT attempt to trim the model
                                (only with fdm=jsbsim)
   --on-ground                  Start at ground level (default)
   --in-air                     Start in air (implied when using --altitude)
   --enable-auto-coordination   Enable auto coordination
   --disable-auto-coordination  Disable auto coordination
   --livery=name                Select aircraft livery
   --vehicle=name               Select an vehicle profile as defined by a top
                                level <name>-set.xml

Time Options:

   --timeofday={real,dawn,morning,noon,afternoon,dusk,evening,midnight}
                                Specify a time of day
   --season={summer,winter}     Specify the startup season
   --time-offset=[+-]hh:mm:ss   Add this time offset
   --time-match-real            Synchronize time with real-world time
   --time-match-local           Synchronize time with local real-world time

   --start-date-sys=yyyy:mm:dd:hh:mm:ss
                                Specify a starting date/time with respect to

   --start-date-gmt=yyyy:mm:dd:hh:mm:ss
                                Specify a starting date/time with respect to

   --start-date-lat=yyyy:mm:dd:hh:mm:ss
                                Specify a starting date/time with respect to

Initial Position and Orientation:
   --airport=ID                 Specify starting position relative to an
                                airport
   --parking-id=name            Specify parking position at an airport (must
                                also specify an airport)
   --runway=rwy_no              Specify starting runway (must also specify an
                                airport)
   --carrier=[name|ID]          Specify starting position on an AI carrier

   --carrier-abeam=[true|false]
                                Start on downwind abeam the selected carrier
                                (must also specify a carrier)
   --parkpos=name               Specify which starting position on an AI
                                carrier (must also specify a carrier)
   --vor=ID                     Specify starting position relative to a VOR
   --vor-frequency=frequency    Specify the frequency of the VOR. Use with
                                --vor=ID
   --ndb=ID                     Specify starting position relative to an NDB
   --ndb-frequency=frequency    Specify the frequency of the NDB. Use with
                                --ndb=ID
   --fix=ID                     Specify starting position relative to a fix
   --offset-distance=nm         Specify distance to reference point (statute
                                miles)
   --offset-azimuth=degrees     Specify heading to reference point
   --lon=degrees                Starting longitude (west = -)
   --lat=degrees                Starting latitude (south = -)
   --altitude=value             Starting altitude
   --heading=degrees            Specify heading (yaw) angle (Psi)
   --roll=degrees               Specify roll angle (Phi)
   --pitch=degrees              Specify pitch angle (Theta)
   --uBody=units_per_sec        Specify velocity along the body X axis
   --vBody=units_per_sec        Specify velocity along the body Y axis
   --wBody=units_per_sec        Specify velocity along the body Z axis
   --vNorth=units_per_sec       Specify velocity along a South-North axis
   --vEast=units_per_sec        Specify velocity along a West-East axis
   --vDown=units_per_sec        Specify velocity along a vertical axis
   --vc=knots                   Specify initial airspeed
   --mach=num                   Specify initial mach number
   --glideslope=degrees         Specify flight path angle (can be positive)
   --roc=fpm                    Specify initial climb rate (can be negative)

Route/Way Point Options:
   --wp=ID[@alt]                Specify a waypoint for the GC autopilot;
   --flight-plan=file           Read all waypoints from a file

Avionics Options:
   --com1=frequency             Set the COM1 radio frequency
   --com2=frequency             Set the COM2 radio frequency
   --nav1=[radial:]frequency    Set the NAV1 radio frequency, optionally
                                preceded by a radial.
   --nav2=[radial:]frequency    Set the NAV2 radio frequency, optionally
                                preceded by a radial.
   --adf1=[rotation:]frequency  Set the ADF1 radio frequency, optionally
                                preceded by a card rotation.
   --adf2=[rotation:]frequency  Set the ADF2 radio frequency, optionally
                                preceded by a card rotation.
   --dme={nav1|nav2|frequency}  Slave the DME to one of the NAV radios, or set
                                its internal frequency.

Environment Options:
   --metar=METAR                Pass a METAR string to set up static weather
                                (this implies --disable-real-weather-fetch)

   --disable-real-weather-fetch
                                Disable METAR based real weather fetching
   --enable-real-weather-fetch  Enable METAR based real weather fetching (this
                                requires an open internet connection)
   --enable-clouds              Enable 2D (flat) cloud layers
   --disable-clouds             Disable 2D (flat) cloud layers
   --enable-clouds3d            Enable 3D (volumetric) cloud layers
   --disable-clouds3d           Disable 3D (volumetric) cloud layers
   --visibility=meters          Specify initial visibility
   --visibility-miles=miles     Specify initial visibility in miles

   --wind=DIR[:MAXDIR]@SPEED[:GUST]
                                Specify wind coming from DIR (degrees) at SPEED
                                (knots)
   --random-wind                Set up random wind direction and speed
   --turbulence=0.0 to 1.0      Specify turbulence from 0.0 (calm) to 1.0
                                (severe)

   --ceiling=FT_ASL[:THICKNESS_FT]
                                Create an overcast ceiling, optionally with a
                                specific thickness (defaults to 2000 ft).

Network Options:
   --callsign                   assign a unique name to a player

   --multiplay={in|out},hz,address,port
                                Specify multipilot communication settings

   --proxy=[user:pwd@]host:port
                                Specify which proxy server (and port) to use.
                                The username and password are optional and
                                should be MD5 encoded already. This option is
                                only useful when used in conjunction with the
                                real-weather-fetch option.
   --httpd=port                 Enable http server on the specified address.
                                Specify the port or address:port to bind to.
   --telnet=port                Enable telnet server on the specified port
   --jpg-httpd=port             Enable screen shot http server on the specified
                                port (replaced by --httpd)
   --disable-terrasync          Disable automatic scenery downloads/updates
   --enable-terrasync           Enable automatic scenery downloads/updates
   --terrasync-dir              Set target directory for scenery downloads
   --enable-fgcom               Enable FGCom built-in
   --disable-fgcom              Disable FGCom built-in

IO Options:
   --generic=params             Open connection using a predefined
                                communication interface and a preselected
                                communication protocol
   --atlas=params               Open connection using the Atlas protocol
   --atcsim=params              Open connection using the ATC sim protocol
                                (atc610x)
   --AV400=params               Emit the Garmin AV400 protocol required to
                                drive a Garmin 196/296 series GPS
   --AV400Sim=params            Emit the set of AV400 strings required to drive
                                a Garmin 400-series GPS from FlightGear
   --flarm=params               Open connection using the Flarm protocol, which
                                includes NMEA/GPS and traffic reporting
                                messages
   --garmin=params              Open connection using the Garmin GPS protocol
   --joyclient=params           Open connection to an Agwagon joystick
   --jsclient=params            Open connection to a remote joystick
   --native-ctrls=params        Open connection using the FG Native Controls
                                protocol
   --native-gui=params          Open connection using the FG Native GUI
                                protocol
   --native-fdm=params          Open connection using the FG Native FDM
                                protocol
   --native=params              Open connection using the FG Native protocol
   --nmea=params                Open connection using the NMEA protocol
   --opengc=params              Open connection using the OpenGC protocol
   --props=params               Open connection using the interactive property
                                manager
   --pve=params                 Open connection using the PVE protocol
   --ray=params                 Open connection using the Ray Woodworth motion
                                chair protocol
   --rul=params                 Open connection using the RUL protocol

Debugging Options:
   --enable-fpe                 Abort on encountering a floating point
                                exception;
   --fgviewer                   Use a model viewer rather than load the entire
                                simulator;

   --log-level={bulk,debug,info,warn,alert}
                                Specify which logging level to use

   --log-class=[ai,environment,flight,general,io,network,sound,terrain,...]
                                Specify which logging class(es) to use
   --log-dir=DIR                Log to directory DIR. The special value
                                'desktop' causes logging to the desktop
                                (OS-dependent location). This option may be
                                given several times, using a different value
                                each time. Inside the specified directory, the
                                written log file is named
                                FlightGear_YYYY-MM-DD_<num>.log, where <num>
                                takes the values 0, 1, 2, etc.
   --trace-read=property        Trace the reads for a property;
   --trace-write=property       Trace the writes for a property;
