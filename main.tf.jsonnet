local security = import "security.libsonnet";
{
    terraform: {
      required_providers:{
         nexus: {
            source: "datadrivers/nexus",
            version: "1.17.0"
         },
      }
   },
    provider:{
        nexus:{
            insecure: true,
            password: "admin",
            url: "http://127.0.0.1:8081",
            username: "admin"
        },
    },
    resource:{
        nexus_blobstore_file:{
            file:{
                name: "blobstore-file",
                path: "/nexus-data/blobstore-file",
                soft_quota:{
                        limit: 1024000000,
                        type: "spaceRemainingQuota"
                },
            },
        },
        nexus_repository_docker_hosted:{
            dockerReleases:{
                name:"dockerReleases",
                online: true,
                docker: {
                    force_basic_auth: false,
                    v1_enabled: false
                },
                storage: {
                    blob_store_name             :"default",
                    strict_content_type_validation:true,
                    write_policy                :"ALLOW"
                }
            },
        },
        // support it soon
        // nexus_repository_docker_proxy:{
        //     dockerhub: {
        //         name: "dockerhub",
        //         online: true,
        //         docker: {
        //             force_basic_auth:false,
        //             v1_enabled      :false
        //         },

        //         docker_proxy: {
        //             index_hub:"HUB"
        //         },

        //         storage: {
        //             blob_store_name: $.resource.nexus_blobstore_file.file.name,
        //             strict_content_type_validation:true
        //         },
        //         proxy: {
        //             remote_url      :"https://registry-1.docker.io",
        //             content_max_age: 1440,
        //             metadata_max_age: 1440
        //         },
        //         negative_cache: {
        //             enabled:true,
        //             time_to_live:1440
        //         },

        //         http_client: {
        //             blocked   :false,
        //             auto_block:true
        //         }
        //     },
        // },
        nexus_repository:{
            apt_hosted:{
                name: "apt-repo",
                format: "apt",
                type: "hosted",
                apt:{
                    distribution:"bionic"
                },

                apt_signing:{
                    keypair: "<keypair>",
                    passphrase: "<passphrase>"
                },
                storage: {
                    blob_store_name: $.resource.nexus_blobstore_file.file.name,
                    strict_content_type_validation: true,
                    write_policy: "ALLOW_ONCE"
                }
            },
            docker_group:{
                name: "docker-group",
                format: "docker",
                type: "group",
                online: true,

                group: {
                    member_names: [
                    $.resource.nexus_repository_docker_hosted.dockerReleases.name,
                    ]
                },

                docker: {
                    force_basic_auth : false,
                    http_port     : 5000,
                    https_port    : 0,
                    v1enabled     : false,
                },

                storage:{
                    blob_store_name: $.resource.nexus_blobstore_file.file.name,
                    strict_content_type_validation: true
                }
            },
             
        },
        nexus_security_role:{
            nx_admin:{
                  roleid: "nx-adminx",
                name: "nx-adminx",
                description: "Administrator role",
                privileges: ["nx-all"]
            },
            docker_deploy:{
                description: "Docker deployment role",
                name: "docker-deploy",
                privileges:[
                    "nx-repository-view-docker-*-*",
                ],
                roleid: "docker-deploy"
            },
        },
        nexus_security_user:{
            "adminx": {
            userid: "adminx",
            firstname: "Administrator",
            lastname: "User",
            email: "nexus@example.com",
            // password: [security.nexus.admin.password],
            password: security.nexus.admin.password,
            roles: [$.resource.nexus_security_role.nx_admin.roleid],
            status: "active"
            },
        },
    },
}