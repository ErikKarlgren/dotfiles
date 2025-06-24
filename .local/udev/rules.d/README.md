# udev rules
Here are some custom udev rules that I want to track in my dotfiles.
- Don't forget to create a symbolic link to these rules so they're present in `/etc/udev/rules.d `
- And then run:
```bash
# Reload udev rules
sudo udevadm control --reload-rules

# Reload systemd 
sudo systemctl daemon-reload
```

udev rules should launch systemd services due to the following:
1. **Better logging** - automatic rotation, timestamps, metadata
2. **Resource control** - can set CPU/memory limits
3. **Dependencies** - can ensure other services are ready
4. **Debugging** - better error messages and status info
5. **Standards** - follows modern Linux conventions
