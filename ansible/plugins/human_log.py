def human_log(res):

    if type(res) == type(dict()):
        #if 'cmd' in res.keys():
        #if 'command' in res.keys():
        #if 'start' in res.keys():
        #if 'end' in res.keys():
        #if 'delta' in res.keys():
        if 'msg' in res.keys() and res['msg']:
            print u'{0}'.format(res['msg'])
        if 'stdout' in res.keys() and res['stdout']:
            print u'{0}'.format(res['stdout'])
        if 'stderr' in res.keys() and res['stderr']:
            print u'{0}'.format(res['stderr'])

class CallbackModule(object):

    def on_any(self, *args, **kwargs):
        pass

    def runner_on_failed(self, host, res, ignore_errors=False):
        human_log(res)

    def runner_on_ok(self, host, res):
        human_log(res)

    def runner_on_error(self, host, msg):
        pass

    def runner_on_skipped(self, host, item=None):
        pass

    def runner_on_unreachable(self, host, res):
        human_log(res)

    def runner_on_no_hosts(self):
        pass

    def runner_on_async_poll(self, host, res, jid, clock):
        human_log(res)

    def runner_on_async_ok(self, host, res, jid):
        human_log(res)

    def runner_on_async_failed(self, host, res, jid):
        human_log(res)

    def playbook_on_start(self):
        pass

    def playbook_on_notify(self, host, handler):
        pass

    def playbook_on_no_hosts_matched(self):
        pass

    def playbook_on_no_hosts_remaining(self):
        pass

    def playbook_on_task_start(self, name, is_conditional):
        pass

    def playbook_on_vars_prompt(self, varname, private=True, prompt=None, encrypt=None, confirm=False, salt_size=None, salt=None, default=None):
        pass

    def playbook_on_setup(self):
        pass

    def playbook_on_import_for_host(self, host, imported_file):
        pass

    def playbook_on_not_import_for_host(self, host, missing_file):
        pass

    def playbook_on_play_start(self, pattern):
        pass

    def playbook_on_stats(self, stats):
        pass