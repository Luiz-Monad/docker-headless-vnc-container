#!/usr/bin/python3
# This file is part of Epoptes, https://epoptes.org
# Copyright 2012-2018 the Epoptes team, see AUTHORS.
# SPDX-License-Identifier: GPL-3.0-or-later
"""
Display a simple window with a message.
"""
import os
import sys
import subprocess

from gi.repository import Gtk


class ExecCommand:
    ui = os.path.join(os.path.dirname(__file__), 'exec_command.ui')

    """Load the dialog and settings into local variables."""
    def __init__(self, command):
        builder = Gtk.Builder()
        builder.add_from_file(os.path.realpath(self.ui))
        self.command = command
        self.dialog = builder.get_object('dlg_exec_command')
        self.dialog.connect("destroy", Gtk.main_quit)
        self.cbt_command = builder.get_object('cbt_command')
        self.ent_command = self.cbt_command.get_child()
        self.btn_execute = builder.get_object('btn_execute')
        self.lbl_title = builder.get_object('lbl_title')
        if self.command != 'up':
            self.lbl_title.set_text('Scale down clients - shutdown:')
        else:
            self.lbl_title.set_text('Scale up clients - create')
        builder.connect_signals(self)
        for cmd in [0, 8]:
            self.cbt_command.append_text(str(cmd))

    def run(self):
        """Show the dialog, then hide it so that it may be reused.
        Return the command.
        """
        reply = self.dialog.run()
        if reply == 1:
            result = self.ent_command.get_text().strip()
            if self.command != 'up':
                result = '0'
            result = ('kubectl scale deployment client-deploy --replicas=%s' % result)
        else:
            result = ''
        self.dialog.hide()

        return result

    def on_ent_command_changed(self, ent_command):
        """Enable execute only when the command is not empty."""
        self.btn_execute.set_sensitive(ent_command.get_text().strip())



class MsgCommand:
    ui = os.path.join(os.path.dirname(__file__), 'msg_command.ui')

    """Load the dialog and settings into local variables."""
    def __init__(self, command):
        builder = Gtk.Builder()
        builder.add_from_file(os.path.realpath(self.ui))
        self.dialog = builder.get_object('dlg_exec_command')
        self.dialog.connect("destroy", Gtk.main_quit)
        self.btn_execute = builder.get_object('btn_execute')
        self.lbl_title = builder.get_object('lbl_title')
        self.lbl_title.set_text(command)
        builder.connect_signals(self)

    def run(self):
        """Show the dialog, then hide it so that it may be reused.
        Return the command.
        """
        reply = self.dialog.run()
        if reply == 1:
            result = 'ok'
        else:
            result = ''
        self.dialog.hide()

        return result



def main():
    window = ExecCommand(sys.argv[1])
    cmd = window.run()
    if cmd != '':
        print(cmd)
        subprocess.Popen(['sh', '-c', cmd])
        window = MsgCommand('Executed')
        window.run()



if __name__ == '__main__':
    main()
