import pytest,os,shutil,glob,subprocess
import termcolor
import requests



def pytest_addoption(parser):
    parser.addoption("--consul",action="store", default=None, help="consul ip address")
    parser.addoption("--pause_on_fail",action="store_true", default=False, help="pause on assert failure")



def pytest_configure(config):
    global report_dir
    if config.getoption('--help'):
        return
    cprint("\nPYTEST_CONFIGURE", 'blue')
    ## prepare report dirs
    report_dir=os.path.dirname(config.getoption("--junit-xml"))
    cprint("Test report: %s" % report_dir,'blue')
    ## report_dir is mounted to containers. should not remove dir. only files
    if os.path.exists(report_dir):
        shutil.rmtree(report_dir)
    os.makedirs(report_dir)

    if config.getoption('--consul'):
        os.environ['CONSUL']=config.getoption('--consul')
        
    if not os.getenv('CONSUL'):
            raise Exception(cprint("ERROR: Please provide --consul or set env var CONSUL",'red'))

    consul=os.getenv('CONSUL')
    cprint("SETTING CONSUL : %s" % consul ,'green')





def pytest_unconfigure(config):
    print("\n")
    cprint("=" * 120 , 'blue')
    cprint("PYTEST_UNCONFIGURE", 'blue')
    ## parse junit result 
    parse_junit_xml_result('junit_result_parser.py',report_dir)
    cprint("TEST COMPLETED : Please  xml test report at %s" % report_dir, 'blue')
    
    

def pytest_runtest_setup(item):
    global pause
    global fh,tc_outfile,stb_ip,tc_log_path, tcName,cpe


    if "incremental" in item.keywords:
        previousfailed = getattr(item.parent, "_previousfailed", None)
        if previousfailed is not None:
            pytest.xfail("previous test failed (%s)" %previousfailed.name)
        if config.getoption('--pause_on_fail'):
            cprint("Test failed . Entering debugging mode" , 'red')
            pytest.set_trace()
    
    try:
        classname="%s.%s" % (item.module.__name__,item.cls.__name__) 
    except:
        classname="%s" % (item.module.__name__)

    tcName="%s.%s" % (classname,item.name)

    print cprint("\n--TC_START %s" % tcName , 'blue')



########################
## Lib functions
########################

def ping(ip,c=5):
    '''
    ex : ping('1.1.1.1')
    return True or False
    '''
    command=os.system('ping -c %d %s' % (c,ip))
    if command == 0:
        return True
    else:
        return False


def cprint(msg, color, attrs=None):
    print termcolor.colored("%s" % msg , color, attrs=attrs)


def parse_junit_xml_result(parser, result_path):
    cprint("Parsing junit result at %s" % (result_path),'blue')
    # get parser
    if not os.path.exists(parser):
        url="https://bitbucket-eng-rtp1.cisco.com/bitbucket/projects/IHDEV/repos/goldengate_tests/browse/utils/%s?raw" % parser
        r=requests.get(url)
        if r.status_code != 200:
            raise("ERROR : url %s failed" % url)
        with open(parser,'w+') as f:
            f.write(r.text)
            run_subprocess("chmod -R 777 %s" % parser)
    cmd="python %s %s" % (parser , result_path)
    output=run_subprocess(cmd)


def run_subprocess(command,realTime=True):
    '''
    examples:
    http://stackoverflow.com/questions/1606795/catching-stdout-in-realtime-from-subprocess
    putil.subprocess('ps ax')
    output=putil.run_subprocess('ps ax',readTime=False) 



    '''
    print("run_subprocess: (%s)" % command)
    cmdList=command.split()
    p = subprocess.Popen(cmdList,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT
                         )
    if realTime:
        for line in iter(p.stdout.readline, b''):
            print(">" + line.rstrip())
    else:
        output=p.stdout.readlines()
        return "".join(output)

