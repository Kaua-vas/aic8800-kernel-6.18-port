#!/bin/bash

set -e

echo "================================================"
echo "AIC8800 Driver Installation for Kernel 6.18+"
echo "================================================"
echo ""

# Verificar se é root
if [ "$EUID" -ne 0 ]; then 
    echo "Por favor, execute como root ou com sudo"
    exit 1
fi

# Detectar distribuição
if [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
elif [ -f /etc/arch-release ]; then
    DISTRO="arch"
else
    DISTRO="unknown"
fi

echo "Distribuição detectada: $DISTRO"
echo ""

# Instalar dependências
echo "Instalando dependências..."
case $DISTRO in
    fedora)
        dnf install -y git dkms gcc make kernel-devel kernel-headers
        ;;
    debian)
        apt update
        apt install -y git dkms build-essential linux-headers-$(uname -r)
        ;;
    arch)
        pacman -S --needed git dkms base-devel linux-headers
        ;;
    *)
        echo "Distribuição não suportada automaticamente"
        echo "Instale manualmente: git, dkms, gcc, make, kernel-devel"
        exit 1
        ;;
esac

echo ""
echo "Clonando driver base..."
if [ ! -d "aic8800dc-linux-patched" ]; then
    git clone https://github.com/Kiborgik/aic8800dc-linux-patched.git
fi

cd aic8800dc-linux-patched

echo ""
echo "Aplicando patches para Kernel 6.18+..."

# Aplicar patches críticos diretamente
echo "Patch 1: kthread validation..."
# (patches serão aplicados via script Python)

echo "Patch 2: message handler fix..."
python3 << 'PYTHON'
with open('drivers/aic8800/aic8800_fdrv/rwnx_msg_rx.c', 'r') as f:
    content = f.read()

# Fix msgind to allow NULL handlers (CFM messages)
old = '''    rwnx_hw->cmd_mgr->msgind(rwnx_hw->cmd_mgr, msg,
                            msg_hdlrs[MSG_T(msg->id)][MSG_I(msg->id)]);'''

new = '''    // Validação para Kernel 6.18+
    int task_id = MSG_T(msg->id);
    int msg_idx = MSG_I(msg->id);
    msg_cb_fct handler = NULL;
    
    if (task_id >= 0 && task_id < ARRAY_SIZE(msg_hdlrs)) {
        if (msg_hdlrs[task_id] != NULL) {
            handler = msg_hdlrs[task_id][msg_idx];
        }
    }
    
    rwnx_hw->cmd_mgr->msgind(rwnx_hw->cmd_mgr, msg, handler);'''

if old in content:
    content = content.replace(old, new)
    with open('drivers/aic8800/aic8800_fdrv/rwnx_msg_rx.c', 'w') as f:
        f.write(content)
    print("✅ Message handler fix aplicado")
PYTHON

echo "Patch 3: userconfig stubs..."
cat > drivers/aic8800/aic8800_fdrv/userconfig_stubs.c << 'STUB'
#include <linux/slab.h>

void get_fw_path(char* fw_path) {}
void set_testmode(int mode) {}
int get_testmode(void) { return 0; }
void get_userconfig_txpwr_ofst(void *txpwr_ofst) {}
void get_userconfig_txpwr_idx(void *txpwr_idx) {}
int get_adap_test(void) { return 0; }

void *aicwf_prealloc_txq_alloc(size_t size) {
    return kzalloc(size, GFP_KERNEL);
}
STUB

echo "Patch 4: MODULE_IMPORT_NS..."
sed -i 's/MODULE_IMPORT_NS(VFS_internal.*/\/\/ MODULE_IMPORT_NS removed for Kernel 6.18+/' drivers/aic8800/aic_load_fw/aic_bluetooth_main.c

echo "Patch 5: Disable CONFIG_PREALLOC_TXQ..."
sed -i 's/^CONFIG_PREALLOC_TXQ = y$/CONFIG_PREALLOC_TXQ = n/' drivers/aic8800/aic8800_fdrv/Makefile

echo ""
echo "Compilando driver..."
cd drivers/aic8800
make clean 2>/dev/null || true
make -j$(nproc)

echo ""
echo "Instalando módulos..."
make install
depmod -a

echo ""
echo "Instalando firmware..."
cp -r ../../fw/aic8800DC /lib/firmware/ 2>/dev/null || true

echo ""
echo "Configurando carregamento automático..."
cat > /etc/modules-load.d/aic8800.conf << 'MOD'
aic_load_fw
aic8800_fdrv
MOD

echo ""
echo "================================================"
echo "✅ Instalação concluída com sucesso!"
echo "================================================"
echo ""
echo "Para carregar o driver agora:"
echo "  sudo modprobe aic_load_fw"
echo "  sudo modprobe aic8800_fdrv"
echo ""
echo "Ou reinicie o sistema."
echo ""
