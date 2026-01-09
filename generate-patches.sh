#!/bin/bash

echo "Gerando patches do código modificado..."

# Copiar código atual para referência
cp -r ~/aic8800-fix drivers_source

echo "✅ Patches prontos em: patches/"
echo ""
echo "Para aplicar em um driver limpo:"
echo "  git clone https://github.com/Kiborgik/aic8800dc-linux-patched.git"
echo "  cd aic8800dc-linux-patched"
echo "  patch -p1 < ../patches/01-kthread-validation.patch"
echo "  # (aplicar outros patches...)"
