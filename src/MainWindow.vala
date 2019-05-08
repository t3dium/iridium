/*
 * Copyright (c) 2019 Andrew Vojak (https://avojak.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Andrew Vojak <andrew.vojak@gmail.com>
 */

public class Iridium.MainWindow : Gtk.ApplicationWindow {

    public Iridium.Widgets.ServerConnectionDialog? connection_dialog = null;
    public Iridium.Widgets.ChannelJoinDialog? channel_join_dialog = null;

    private Iridium.Views.Welcome welcome_view;
    private Iridium.Widgets.HeaderBar header_bar;
    private Iridium.Widgets.SidePanel side_panel;
    private Iridium.Layouts.MainLayout main_layout;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            border_width: 0,
            resizable: true,
            title: "Iridium",
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        header_bar = new Iridium.Widgets.HeaderBar ();
        set_titlebar (header_bar);

        // TODO: Show an info bar across the top of the window area when internet connection is lost

        welcome_view = new Iridium.Views.Welcome ();
        side_panel = new Iridium.Widgets.SidePanel ();

        main_layout = new Iridium.Layouts.MainLayout (welcome_view, side_panel);
        add (main_layout);

        resize (900, 600);

        // Connect to signals
        header_bar.server_connect_button_clicked.connect (() => {
            show_server_connection_dialog ();
        });
        header_bar.channel_join_button_clicked.connect (() => {
            show_channel_join_dialog ();
        });
        welcome_view.new_connection_button_clicked.connect (() => {
            show_server_connection_dialog ();
        });
    }

    private void show_server_connection_dialog () {
        if (connection_dialog == null) {
            connection_dialog = new Iridium.Widgets.ServerConnectionDialog (this);
            connection_dialog.show_all ();
            connection_dialog.connect_button_clicked.connect ((server, nickname, username, realname) => {
                var connection_details = new Iridium.Services.ServerConnectionDetails ();
                connection_details.server = server;
                connection_details.nickname = nickname;
                connection_details.username = username;
                connection_details.realname = realname;

                var chat_view = new Iridium.Views.ChatView ();
                main_layout.add_chat_view (chat_view, server);
                var buffer = chat_view.get_buffer ();

                var server_connection = Iridium.Application.connection_handler.connect_to_server (connection_details, buffer);
                server_connection.open_successful.connect (() => {
                    connection_dialog.dismiss ();
                    side_panel.add_server (server);
                    main_layout.show_chat_view (server);
                });
                server_connection.open_failed.connect ((message) => {
                    connection_dialog.display_error (message);
                    main_layout.remove_chat_view (server);
                });
            });
            connection_dialog.destroy.connect (() => {
                connection_dialog = null;
            });
        }
        connection_dialog.present ();
    }

    private void show_channel_join_dialog () {
        if (channel_join_dialog == null) {
            channel_join_dialog = new Iridium.Widgets.ChannelJoinDialog (this);
            channel_join_dialog.show_all ();
            channel_join_dialog.destroy.connect (() => {
                channel_join_dialog = null;
            });
        }
        channel_join_dialog.present ();
    }

}
