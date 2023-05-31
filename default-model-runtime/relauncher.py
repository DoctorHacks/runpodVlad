import os, time

n = 0
while True:
    print('Relauncher: Launching...')
    launch_string = "/workspace/automatic/webui.sh -f"
    if n == 0:
        # On first launch, pass 'y' as user input to download default model
        # If n == 0 from a restart, this "y" is never read
        os.system("echo \"y\" | " + launch_string)
    else:
        print(f'\tRelaunch count: {n}')
        os.system(launch_string)
    print('Relauncher: Process is ending. Relaunching in 2s...')
    n += 1
    time.sleep(2)
