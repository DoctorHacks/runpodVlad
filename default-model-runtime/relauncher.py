import os, time

n = 0
while True:
    print('Relauncher: Launching...')
    if n > 0:
        print(f'\tRelaunch count: {n}')
    launch_string = "/workspace/automatic/webui.sh -f"
    if n == 0:
        # 'y' input to download default model (never read if not needed)
        os.system("echo 'y' | " + launch_string)
    else:
        os.system(launch_string)
    print('Relauncher: Process is ending. Relaunching in 2s...')
    n += 1
    time.sleep(2)
