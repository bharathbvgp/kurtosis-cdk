def run(plan, args):
    blutgang_name = "blutgang" + args["deployment_suffix"]
    blutgang_config_template = read_file(
        src="./templates/blutgang/blutgang-config.toml"
    )

    blutgang_config_artifact = plan.render_templates(
        name="blutgang-config-artifact",
        config={
            "blutgang-config.toml": struct(template=blutgang_config_template, data=args)
        },
    )

    blutgang_service_config = ServiceConfig(
        image=args["blutgang_image"],
        ports={
            "http": PortSpec(args["blutgang_rpc_port"], application_protocol="http"),
            "admin": PortSpec(args["blutgang_admin_port"], application_protocol="http"),
        },
        files={
            "/etc/blutgang": Directory(
                artifact_names=[
                    blutgang_config_artifact,
                ]
            ),
        },
        cmd=["/app/blutgang", "-c", "/etc/blutgang/blutgang-config.toml"]
    )

    plan.add_service(
        name=blutgang_name,
        config=blutgang_service_config,
        description="Starting blutgang service",
    )