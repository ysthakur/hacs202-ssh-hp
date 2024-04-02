'use strict';

module.exports = {
    local: false,
    debug : true,
    container : {
        ipAddress: '172.20.0.2',
        name: 'ssh-hp',
        mountPath: {
            prefix: '/var/snap/lxd/common/mntns/var/snap/lxd/common/lxd/storage-pools/default/containers/',
            suffix: 'rootfs'
        }
    },
    logging : {
        streamOutput : '/root/MITM_data/sessions',
        loginAttempts : '/root/MITM_data/login_attempts',
        logins : '/root/MITM_data/logins'
    },
    server : {
        maxAttemptsPerConnection: 200,
        listenIP: '0.0.0.0',
        listenPort: 1024,
        identifier : 'SSH-2.0-OpenSSH_6.6.1p1 Ubuntu-2ubuntu2',
        bannerFile : ''
    },
    autoAccess : {
        enabled: true,
        cacheSize : 5000,
        barrier: {
            normalDist: {
                enabled: true,
                mean: 6,
                standardDeviation: 1,
            },
            fixed: {
                enabled: false,
                upperLimit: true,
                attempts: 3,
            },
        }

    }
};
