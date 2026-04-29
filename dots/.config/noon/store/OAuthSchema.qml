import qs.common.utils

JsonAdapter {
    property JO dictionary: JO {
        property JO calendar: JO {
            property string id
            property string secret
            property var scopes
        }
        property JO tasks: JO {
            property string id
            property string secret
            property var scopes
        }
    }
}
