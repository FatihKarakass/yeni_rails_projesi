#!/usr/bin/env python3
"""
Şifre sıfırlama e-postasından temiz link çıkarır
Kullanım: python3 bin/get_reset_link.py
"""

import os
import re
import glob

def extract_reset_link():
    mails_dir = 'tmp/mails'
    
    if not os.path.exists(mails_dir):
        print("❌ E-posta klasörü bulunamadı!")
        return
    
    # En yeni e-posta dosyasını bul
    mail_files = glob.glob(f'{mails_dir}/*')
    if not mail_files:
        print("❌ E-posta dosyası bulunamadı!")
        return
    
    latest_mail = max(mail_files, key=os.path.getmtime)
    print(f"📧 E-posta dosyası: {latest_mail}")
    
    with open(latest_mail, 'r') as f:
        content = f.read()
    
    # Token parçalarını birleştir
    lines = content.split('\n')
    token_parts = []
    collecting = False
    
    for line in lines:
        if 'http://localhost:3000/password/reset/edit?token=3D' in line:
            # İlk token parçası
            token_part = line.split('token=3D')[1]
            token_parts.append(token_part)
            collecting = True
        elif collecting and line and not line.startswith('-') and not line.startswith('<') and not 'If you' in line:
            # Devam eden token parçaları
            token_parts.append(line.rstrip('='))
        elif collecting and (line.startswith('-') or 'If you' in line):
            break
    
    # Token'ı birleştir ve temizle
    full_token = ''.join(token_parts).replace('=', '')
    if full_token:
        clean_url = f'http://localhost:3000/password/reset/edit?token={full_token}'
        print('\n✅ ÇALIŞAN LİNK:')
        print(clean_url)
        print('\n📋 Bu linki kopyalayıp tarayıcınıza yapıştırın!')
    else:
        print('❌ Token bulunamadı')

if __name__ == '__main__':
    extract_reset_link()
