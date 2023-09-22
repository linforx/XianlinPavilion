export default interface Config {
    selected_account: {
        account_id: string,
        cookie: string,
        genshin_impact: {
            selected_role: {
                uid: string,
                server: string
            }
        },
        star_rail: {
            selected_role: {
                uid: string,
                server: string
            }
        }
    }
}