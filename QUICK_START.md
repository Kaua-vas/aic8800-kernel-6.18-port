# Quick Start Guide

## Para Usuários (Instalar o Driver)

```bash
# Clone o repositório
git clone https://github.com/SEU_USUARIO/aic8800-kernel-6.18-port.git
cd aic8800-kernel-6.18-port

# Execute o instalador automático
chmod +x install.sh
sudo ./install.sh

# Reinicie para carregar o driver
sudo reboot
```

Após o reboot, seu Wi-Fi deve aparecer automaticamente como `wlan0`.

## Para Desenvolvedores (Aplicar Patches Manualmente)

```bash
# Clone o driver base
git clone https://github.com/Kiborgik/aic8800dc-linux-patched.git
cd aic8800dc-linux-patched

# Clone este repositório de patches
git clone https://github.com/SEU_USUARIO/aic8800-kernel-6.18-port.git patches-repo

# Aplique os patches
cd patches-repo
chmod +x apply-patches.sh
./apply-patches.sh ~/aic8800dc-linux-patched

# Compile e instale
cd ~/aic8800dc-linux-patched
./build.sh
sudo ./install.sh
```

## Troubleshooting Rápido

**Wi-Fi não aparece?**
```bash
sudo dmesg | grep -i aic
lsusb | grep a69c
```

**Driver não carrega?**
```bash
sudo modprobe aic_load_fw
sudo modprobe aic8800_fdrv
```

**Precisa de ajuda?**
- Leia [README.md](README.md) completo
- Consulte [TECHNICAL.md](TECHNICAL.md) para detalhes
- Abra uma issue no GitHub

## Verificar Instalação

```bash
# Ver se os módulos estão carregados
lsmod | grep aic

# Ver interface Wi-Fi
ip link show wlan0

# Testar conectividade
ping -c4 8.8.8.8
```

---

**Versão**: 1.0.0  
**Kernel Mínimo**: 6.18+  
**Status**: Produção
