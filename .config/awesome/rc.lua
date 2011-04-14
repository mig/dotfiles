-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
require("vicious")
-- Notification library
-- require("naughty")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init("/usr/share/awesome/themes/default/theme.lua")
-- beautiful.init("~/.config/awesome/theme.lua")
-- beautiful.init("/home/chimo/.config/awesome/theme.lua")
beautiful.init("/home/chimo/.config/awesome/theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    -- tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
    tags[s] = awful.tag({ 1, 2, 3, 4}, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })
-- mytextbox = widget({ type = "textbox" })
-- mytextbox.text = "::"

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
--            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
--        mylayoutbox[s],
--        mytextbox,
--        mytextclock,
--        batterywidget,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Widgets

-- Containers
topbar = {}
bottombar = {}

-- Generic widgets
clock = awful.widget.textclock({align = "right"}, "%a %b %d, %I:%M %p")
mysystray = widget({ type = "systray" })
seperator = widget({ type = "textbox" })
seperator.text = " | "
spacer = widget({ type = "textbox" })
spacer.width = 6

-- Set all the icons needed
-- For some reason, type "imagebox" inflates the images and seems
-- to offer no way to resize them down. So a textbox is set with
-- a background image to do the job right.
baticon = widget ({ type = "textbox" })
baticon.bg_image = image(beautiful.widget_batt_full)
baticon.bg_align = "middle"
baticon.width = 8
pkgicon = widget ({ type = "textbox" })
pkgicon.bg_image = image(beautiful.widget_pacman)
pkgicon.bg_align = "middle"
pkgicon.width = 8
cpuicon = widget ({ type = "textbox" })
cpuicon.bg_image = image(beautiful.widget_cpu)
cpuicon.bg_align = "middle"
cpuicon.width = 8
tempicon = widget ({ type = "textbox" })
tempicon.bg_image = image(beautiful.widget_temp)
tempicon.bg_align = "middle"
tempicon.width = 8
memicon = widget ({ type = "textbox" })
memicon.bg_image = image(beautiful.widget_mem)
memicon.bg_align = "middle"
memicon.width = 8
netdownicon = widget ({ type = "textbox" })
netdownicon.bg_image = image(beautiful.widget_netdown)
netdownicon.bg_align = "middle"
netdownicon.width = 8
netupicon = widget ({ type = "textbox" })
netupicon.bg_image = image(beautiful.widget_netup)
netupicon.bg_align = "middle"
netupicon.width = 8
mailicon = widget ({ type = "textbox" })
mailicon.bg_image = image(beautiful.widget_mail)
mailicon.bg_align = "middle"
mailicon.width = 8
clockicon = widget ({ type = "textbox" })
clockicon.bg_image = image(beautiful.widget_clock)
clockicon.bg_align = "middle"
clockicon.width = 8
mpdicon = widget ({ type = "textbox" })
mpdicon.bg_align = "middle"

-- Create some widgets...
batinfo = widget ({ type = "textbox" })
pkginfo = widget ({ type = "textbox" })
cpuinfo = widget ({ type = "textbox" })
cputemp = widget ({ type = "textbox" })
meminfo = widget ({ type = "textbox" })
netdowninfo = widget ({ type = "textbox" })
netupinfo = widget ({ type = "textbox" })
mailinfo = widget ({ type = "textbox" })
mpdinfo = widget ({ type = "textbox" })

-- ... And register them
vicious.register(batinfo, vicious.widgets.bat, "$2%", 61, "BAT1")
vicious.register(pkginfo, vicious.widgets.pkg, "$1", 3571, "Arch")
vicious.register(cpuinfo, vicious.widgets.cpu, "$1% / $2% / $3%")
vicious.register(cputemp, vicious.widgets.thermal, "$1 C", 19, "thermal_zone0")
vicious.cache(vicious.widgets.mem)
vicious.register(meminfo, vicious.widgets.mem, "$1% ($2Mb)", 5)
vicious.cache(vicious.widgets.net)
vicious.register(netdowninfo, vicious.widgets.net, "${wlan0 down_kb}", 
3)
vicious.register(netupinfo, vicious.widgets.net, "${wlan0 up_kb}", 3)
vicious.register(mailinfo, vicious.widgets.gmail,
  function (widget, args)
    if args["{count}"] == 0 then
      mailicon.bg_image = image(beautiful.widget_mail)
      return 0
    else
      mailicon.bg_image = image(beautiful.widget_newmail)
      return args["{count}"]
    end
  end, 61)

-- MPD widget. Hides icon and text when nothing is playing.
vicious.register(mpdinfo, vicious.widgets.mpd,
  function (widget, args)
    if args["{state}"] == "Stop" then
      mpdicon.bg_image = nil
      mpdicon.width = 0 
      return ""
    else
      mpdicon.bg_image = image(beautiful.widget_mpd)
      mpdicon.width = 8
      return "MPD: " .. args["{Artist}"] .. ' - ' .. args["{Title}"]
    end
  end)
  

-- Create a wibox for each screen and add it
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Set a screen margin, for borders
    awful.screen.padding( screen[s], {top = 1, bottom = 1} )

    -- Create the layout box, taglist, and tasklist widgets
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
    mytasklist[s] = awful.widget.tasklist( function(c)
                      local text, bg, status_image, icon = awful.widget.tasklist.label.currenttags(c,s)
                      return text, bg, status_image, nil
                      end, mytasklist.buttons)

    -- Create the bars
    topbar[s] = awful.wibox({
                position = "top", screen = s, height = 13,
                fg = beautiful.fg_normal, bg = beautiful.bg_normal,
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
    })
    bottombar[s] = awful.wibox({
                position = "bottom", screen = s, height = 13,
                fg = beautiful.fg_normal, bg = beautiful.bg_normal,
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal
    })

    -- Fill the bars with widgets
    right_aligned = { layout = awful.widget.layout.horizontal.rightleft}
    if s == 1 then table.insert(right_aligned, mysystray) end
    table.insert(right_aligned, mylayoutbox[s])
    topbar[s].widgets = {
        mytaglist[s],
        { mylayoutbox[s], spacer, mysystray,
          layout = awful.widget.layout.horizontal.rightleft
        },
	mytasklist[s],
        layout = awful.widget.layout.horizontal.leftright,
        height = 13
    }
    bottombar[s].widgets = { 
      { spacer, mpdicon, spacer, mpdinfo,
        layout = awful.widget.layout.horizontal.leftright
      },
      spacer, clock, spacer, clockicon, seperator, pkginfo, spacer, pkgicon, seperator, mailinfo, spacer,
      mailicon, seperator, netupinfo, spacer, netupicon, spacer, netdowninfo,
      spacer, netdownicon, seperator, meminfo, spacer, memicon,
      seperator, cputemp, spacer, tempicon, seperator, batinfo, spacer, baticon, seperator, cpuinfo, spacer, cpuicon,
      layout = awful.widget.layout.horizontal.rightleft,
      height = 13
   }
end
-- }}}
