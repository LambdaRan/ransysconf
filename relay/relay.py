#!/usr/bin/env python3
# -*- coding:utf-8 -*-

"""
模块说明
参考：https://github.com/emptyhua/sshgo

"""

import os
import sys
import json
import re
import curses
import locale
import logging
# from optparse import OptionParser

locale.setlocale(locale.LC_ALL, '')

HOST_CONF = os.path.expanduser("~/.relay/hosts.json")
LOG_FILE = os.path.expanduser("~/.relay/relay.log")
LOGIN_SCRIPT = sys.path[0] + "/login.sh"
EDITOR = "vim"

logging.basicConfig(level=logging.DEBUG,
                    filename=LOG_FILE,
                    format="%(levelname)s: %(asctime)s [%(filename)s:%(lineno)s] %(message)s",
                    datefmt="%Y-%m-%d %H:%M:%S")

class SSHConf(object):
    """
    读取配置文件
    """
    def __init__(self, config_file):
        self._conf = config_file
        self._ready = False
        self._user_infos = None
        self._host_tree =  {'line_number':None,'expanded':True,'line':None,'sub_lines':[]}

    def _load_config(self):
        if not os.path.exists(self._conf):
            logging.error("Host configuration file not exists")
            return False
        dict_conf = {}
        with open(self._conf, "r", encoding="utf-8") as josnFile:
            dict_conf = json.load(josnFile)
            if not dict_conf:
                logging.error("Host configuration file syntax error")
                return False
        # 获取账号信息
        self._user_infos = {
            "user" : dict_conf["user_infos"]["user"],
            "password" : dict_conf["user_infos"]["password"],
            "relay_host" : dict_conf["user_infos"]["relay_host"]
        }

        # 整理数据
        line_number = 0
        for group in dict_conf['host_infos']:
            line_number += 1
            group_node = {
                "level": 0,
                "expanded": True,
                "line_number": line_number,
                "line":group["group"],
                "user":"",
                "password":"",
                "command":"",
                "sub_lines":[]
            }
            for host in group["hosts"]:
                line_number += 1
                host_node = {
                    "level": 1,
                    "expanded": True,
                    "line_number": line_number,
                    "line": host["host"],
                    "user": host["user"],
                    "password": host["password"],
                    "command": host["command"],
                    "sub_lines":[]
                }
                group_node["sub_lines"].append(host_node)
                # self._host_tree.append(host_node)
            # self._host_tree.append(group_node)
            self._host_tree["sub_lines"].append(group_node)
        self._ready = True
        logging.info("load configuration file success")
        return True

    def get_all_hosts(self):
        if not self._ready:
            self._load_config()
        return self._host_tree

    def get_user_infos(self):
        if not self._ready:
            self._load_config()
        return self._user_infos

class SSHManager(object):
    """ssh host 管理"""
    UP = -1
    DOWN = 1

    KEY_O = 79
    KEY_R = 82
    KEY_G = 71
    KEY_o = 111
    KEY_r = 114
    KEY_g = 103
    KEY_c = 99
    KEY_C = 67
    KEY_m = 109
    KEY_M = 77
    KEY_d = 0x64
    KEY_u = 0x75
    KEY_SPACE = 32
    KEY_ENTER = 10
    KEY_q = 113
    KEY_ESC = 27
    KEY_V = 86
    KEY_n = 110

    KEY_j = 106
    KEY_k = 107
    KEY_f = 102

    KEY_SPLASH = 47

    # screen = None
    HOST_POS = 60

    def __init__(self, conf_obj, script):
        self.hosts_tree = conf_obj.get_all_hosts()
        self.user_infos = conf_obj.get_user_infos()
        self.script = script
        # stdscr = curses.initscr()
        # self.screen = stdscr.subwin(1, 0, 0, 0)
        self.screen = curses.initscr()
        curses.noecho()
        curses.cbreak()
        curses.curs_set(0)

        self.screen.keypad(True)
        self.screen.border(0)

        self.top_line_number = 0
        self.highlight_line_number = 0
        self.search_keyword = None
        self.host_number = None

        curses.start_color()
        curses.use_default_colors()

        #highlight
        curses.init_pair(2, curses.COLOR_WHITE, curses.COLOR_BLUE)
        self.COLOR_HIGHLIGHT = 2

        #red
        curses.init_pair(3, curses.COLOR_RED, -1)
        self.COLOR_RED = 3

        #red highlight
        curses.init_pair(4, curses.COLOR_RED, curses.COLOR_BLUE)
        self.COLOR_RED_HIGH = 4

        #white bg
        curses.init_pair(5, curses.COLOR_BLACK, curses.COLOR_WHITE)
        self.COLOR_WBG = 5

        #black bg
        curses.init_pair(6, curses.COLOR_BLACK, curses.COLOR_BLACK)
        self.COLOR_BBG = 6
        self.run()

    def run(self):
        key_actions = {
            curses.KEY_UP: self.move_up,
            curses.KEY_DOWN: self.move_down,
            self.KEY_k: self.move_up,
            self.KEY_j: self.move_down,
            self.KEY_ENTER: self.toggle_node,
            self.KEY_SPACE: self.toggle_node,
            self.KEY_f: self.toggle_node,
            self.KEY_ESC : self.exit,
            self.KEY_q: self.exit,
            self.KEY_O: self.open_all,
            self.KEY_M: self.open_all,
            self.KEY_o: self.open_node,
            self.KEY_m: self.open_node,
            self.KEY_C: self.close_all,
            self.KEY_R: self.close_all,
            self.KEY_c: self.close_node,
            self.KEY_r: self.close_node,
            self.KEY_g: self.page_top,
            self.KEY_G: self.page_bottom,
            self.KEY_SPLASH: self.enter_search_mode,
            self.KEY_V: self.open_conf,

            self.KEY_n: self.select_host_number,
        }
        while True:
            self.render_screen()
            key = self.screen.getch()
            action = key_actions.get(key, self.empty_action)
            action()

    def empty_action(self):
        pass

    def open_conf(self):
        command = EDITOR + " " + HOST_CONF
        os.system(command)

    def exit(self):
        if self.search_keyword is not None or self.host_number is not None:
            self.search_keyword = None
            self.host_number = None
        else:
            sys.exit(0)

    def enter_search_mode(self):
        screen_cols = curses.tigetnum('cols')
        self.screen.addstr(0, 0, '/' + ' ' * screen_cols)
        curses.echo()
        curses.curs_set(1)
        self.search_keyword = self.screen.getstr(0, 1).decode('utf-8')
        curses.noecho()
        curses.curs_set(0)
        logging.info("search keyword: %s" % self.search_keyword)

    def select_host_number(self):
        # screen_cols = curses.tigetnum('cols')
        host = 'host: '
        self.screen.addstr(0, self.HOST_POS, host)
        curses.echo()
        curses.curs_set(1)
        self.host_number = self.screen.getstr(0, self.HOST_POS + len(host)).decode('utf-8')
        curses.noecho()
        curses.curs_set(0)
        logging.info("host number: %s" % self.host_number)

    def _get_visible_lines_for_render(self):
        lines = []
        stack = self.hosts_tree['sub_lines'] + []
        while len(stack):
            node = stack.pop()
            lines.append(node)
            if node['expanded'] and len(node['sub_lines']):
                stack = stack + node['sub_lines']

        lines.sort(key=lambda n:n['line_number'], reverse=False)
        return lines

    def _search_node(self):
        rt = []
        try:
            kre = re.compile(self.search_keyword, re.I)
        except:
            return rt
        for group in self.hosts_tree["sub_lines"]:
            for node in group["sub_lines"]:
                if len(node['sub_lines']) == 0 and kre.search(node['line']) is not None:
                    rt.append(node)
        return rt

    def get_lines(self):
        if self.search_keyword is not None:
            return self._search_node()
        else:
            return self._get_visible_lines_for_render()

    def page_top(self):
        self.top_line_number = 0
        self.highlight_line_number = 0

    def page_bottom(self):
        screen_lines = curses.tigetnum('lines')
        visible_hosts = self.get_lines()
        self.top_line_number = max(len(visible_hosts) - screen_lines, 0)
        self.highlight_line_number = min(screen_lines, len(visible_hosts)) - 1

    def open_node(self):
        visible_hosts = self.get_lines()
        linenum = self.top_line_number + self.highlight_line_number
        node = visible_hosts[linenum]
        if not len(node['sub_lines']):
            return
        stack = [node]
        while len(stack):
            node = stack.pop()
            node['expanded'] = True
            if len(node['sub_lines']):
                stack = stack + node['sub_lines']

    def close_node(self):
        visible_hosts = self.get_lines()
        linenum = self.top_line_number + self.highlight_line_number
        node = visible_hosts[linenum]
        if not len(node['sub_lines']):
            return
        stack = [node]
        while len(stack):
            node = stack.pop()
            node['expanded'] = False
            if len(node['sub_lines']):
                stack = stack + node['sub_lines']

    def open_all(self):
        for node in self.hosts_tree['sub_lines']:
            if len(node['sub_lines']):
                node['expanded'] = True

    def close_all(self):
        for node in self.hosts_tree['sub_lines']:
            if len(node['sub_lines']):
                node['expanded'] = False

    def toggle_node(self):
        visible_hosts = self.get_lines()
        linenum = self.top_line_number + self.highlight_line_number
        node = visible_hosts[linenum]
        if len(node['sub_lines']):
            node['expanded'] = not node['expanded']
        else:
            self.restore_screen()
            host_addr = node['line']
            if self.host_number is not None and host_addr[0].isdigit():
                host_addr = self.host_number + host_addr.lstrip('0123456789 ')
            exe_args = [self.script,
                        self.user_infos["user"],
                        self.user_infos["relay_host"],
                        host_addr,
                        node['user'],
                        node['password'],
                        node['command']
            ]
            os.execvp(self.script, exe_args)

    def render_screen(self):
        # clear screen
        self.screen.clear()

        # now paint the rows
        screen_lines = curses.tigetnum('lines')
        screen_cols = curses.tigetnum('cols')
        if self.highlight_line_number >= screen_lines:
            self.highlight_line_number = screen_lines - 1

        all_nodes = self.get_lines()
        if self.top_line_number >= len(all_nodes):
            self.top_line_number = 0

        top = self.top_line_number
        bottom = self.top_line_number + screen_lines
        nodes = all_nodes[top:bottom]

        if not len(nodes):
            self.screen.refresh()
            return

        if self.highlight_line_number >= len(nodes):
            self.highlight_line_number = len(nodes) - 1

        if self.top_line_number >= len(all_nodes):
            self.top_line_number = 0
        for (index,node,) in enumerate(nodes):
            #linenum = self.top_line_number + index

            line = node['line']
            if len(node['sub_lines']):
                line += '(%d)' % len(node['sub_lines'])

            prefix = ''
            if self.search_keyword is None:
                prefix += '  ' * node['level']
            if len(node['sub_lines']):
                if node['expanded']:
                    prefix += '-'
                else:
                    prefix += '+'
            else:
                prefix += 'o'
            prefix += ' '

            # highlight current line
            if index != self.highlight_line_number:
                self.screen.addstr(index, 0, prefix, curses.color_pair(self.COLOR_RED))
                self.screen.addstr(index, len(prefix), line)
            else:
                self.screen.addstr(index, 0, prefix, curses.color_pair(self.COLOR_RED_HIGH))
                self.screen.addstr(index, len(prefix), line, curses.color_pair(self.COLOR_HIGHLIGHT))

        if self.host_number is not None:
            prefix_size = 0
            if nodes:
                prefix_size += len(nodes[0]['line'])
            if prefix_size < self.HOST_POS:
                 prefix_size = self.HOST_POS
            host_view = 'host: '
            self.screen.addstr(0, prefix_size, host_view, curses.color_pair(self.COLOR_RED))
            self.screen.addstr(0, prefix_size + len(host_view), self.host_number)
        self.screen.refresh()

    # move highlight up/down one line
    def updown(self, increment):
        visible_hosts = self.get_lines()
        visible_lines_count = len(visible_hosts)
        next_line_number = self.highlight_line_number + increment
        screen_lines = curses.tigetnum('lines')
        # screen_cols = curses.tigetnum('cols')
        # paging
        if increment < 0 and self.highlight_line_number == 0 and self.top_line_number != 0:
            self.top_line_number += self.UP
            return
        elif increment > 0 and next_line_number == screen_lines and (self.top_line_number + screen_lines) != visible_lines_count:
            self.top_line_number += self.DOWN
            return

        # scroll highlight line
        if increment < 0 and (self.top_line_number != 0 or self.highlight_line_number != 0):
            self.highlight_line_number = next_line_number
        elif increment > 0 and (self.top_line_number + self.highlight_line_number + 1) != visible_lines_count and self.highlight_line_number != screen_lines:
            self.highlight_line_number = next_line_number

    def move_up(self):
        self.updown(-1)

    def move_down(self):
        self.updown(1)

    def restore_screen(self):
        # curses.initscr()
        self.screen.clear()
        self.screen.refresh()
        self.screen.keypad(False)
        curses.nocbreak()
        curses.echo()
        curses.endwin()

    # catch any weird termination situations
    def __del__(self):
        self.restore_screen()

if __name__ == '__main__':
    sshconf = SSHConf(HOST_CONF)
    # all_lines = sshconf.get_all_hosts()
    # ret = json.dumps(all_lines)
    # print(ret)
    sshgo = SSHManager(sshconf, LOGIN_SCRIPT)
