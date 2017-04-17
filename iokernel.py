from ipykernel.kernelbase import Kernel
from pexpect import replwrap, EOF
from subprocess import check_output

import re
import signal

crlf_pat = re.compile(r'[\r\n]+')

class IoKernel(Kernel):
    implementation = 'Io'
    implementation_version = '0.0.1'

    language_info = {
        'name': 'Io',
        'codemirror_mode': 'scheme',
        'mimetype': 'text/plain',
        'file_extension': '.io'
    }

    _language_version = None


    @property
    def language_version(self):
        if self._language_version is None:
            self._language_version = check_output(['io', '--version']).decode('utf-8')
        return self._language_version

    @property
    def banner(self):
        return u'Simple Io Kernel (%s)' % self.language_version

    def __init__(self, **kwargs):
        Kernel.__init__(self, **kwargs)
        self._start_io()

    def _start_io(self):
        sig = signal.signal(signal.SIGINT, signal.SIG_DFL)
        try:
            self.iowrapper = replwrap.REPLWrapper("io", "Io> ", None)
        finally:
            signal.signal(signal.SIGINT, sig)

    def do_execute(self, code, silent, store_history=True,
                   user_expressions=None, allow_stdin=False):
        code = crlf_pat.sub(' ', code.strip())
        if not code:
            return {'status': 'ok', 'execution_count': self.execution_count,
                    'payload': [], 'user_expressions': {}}

        interrupted = False
        try:
            output = self.iowrapper.run_command(code, timeout=None)
        except KeyboardInterrupt:
            self.iowrapper.child.sendintr()
            interrupted = True
            self.iowrapper._expect_prompt()
            output = self.iowrapper.child.before
        except EOF:
            output = self.iowrapper.child.before + 'Restarting Io'
            self._start_io()

        if not silent:
            # Send standard output
            stream_content = {'name': 'stdout', 'text': output}
            self.send_response(self.iopub_socket, 'stream', stream_content)

        if interrupted:
            return {'status': 'abort', 'execution_count': self.execution_count}

        return {'status': 'ok', 'execution_count': self.execution_count,
                'payload': [], 'user_expressions': {}}

# ===== MAIN =====
if __name__ == '__main__':
    from IPython.kernel.zmq.kernelapp import IPKernelApp
    IPKernelApp.launch_instance(kernel_class=IoKernel)
