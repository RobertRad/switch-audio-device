#!/usr/bin/env ruby

def load_gtk2
	begin
		require 'gtk2'
	rescue LoadError
		puts "Trying to install gtk2. If it doesn't work try it yourself with \"gem install gtk2\"."
		puts "After the successful install start this program again."
		system("gem install gtk2")
		exit 1
	end
end

load_gtk2
require 'yaml'

devices = YAML.load_file('switch-audio-device.yaml')
puts devices.inspect

###**************************###
## Displayed Icon
###**************************###
si=Gtk::StatusIcon.new
##use a stock image-
si.stock=Gtk::Stock::DIALOG_INFO
##or a personnal one
si.pixbuf=Gdk::Pixbuf.new("sound.png")
si.tooltip='StatusIcon'

###**************************###
## Handle left click on icon
###**************************###

###**************************###
## Pop up menu on rigth click
###**************************###

menu=Gtk::Menu.new
devices.each {|device|
	device_item=Gtk::ImageMenuItem.new(device)
	device_item.signal_connect('activate'){
		puts "Activating: #{device}"
		begin
			command = "nircmd.exe setdefaultsounddevice #{device}"
			out = `#{command}`
		rescue
			msg = "Error, can't open \"nircmd.exe\" - please put it in your path."
			dialog = Gtk::Dialog.new("Error",
                             $main_application_window,
                             Gtk::Dialog::DESTROY_WITH_PARENT,
                             [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_NONE ])
			dialog.signal_connect('response') { dialog.destroy }
			
			dialog.vbox.add(Gtk::Label.new(msg))
			dialog.show_all
			puts msg
		end
	}
	menu.append(device_item)
}
menu.append(Gtk::SeparatorMenuItem.new)
quit=Gtk::ImageMenuItem.new(Gtk::Stock::QUIT)
quit.signal_connect('activate'){Gtk.main_quit}
menu.append(quit)
menu.show_all
##Show menu on rigth click
si.signal_connect('popup-menu'){|tray, button, time| menu.popup(nil, nil, button, time)}


###**************************###
## Main loop
###**************************###
Gtk.main
