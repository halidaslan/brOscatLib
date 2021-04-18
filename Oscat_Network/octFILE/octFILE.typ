TYPE
    FILE_PATH_DATA :    STRUCT
        DRIVE : STRING[3]; (**)
        DIRECTORY : STRING[OSCAT_BASIC.STRING_LENGTH]; (**)
        FILENAME : STRING[255]; (**)
    END_STRUCT;
    FILE_SERVER_DATA :    STRUCT
        FILE_OPEN : BOOL; (**)
        FILENAME : STRING[255]; (**)
        MODE : BYTE; (**)
        OFFSET : UDINT; (**)
        FILE_SIZE : UDINT; (**)
        ERROR : BYTE; (**)
        RUNTIME : FILE_SERVER_RUNTIME_DATA; (**)
    END_STRUCT;
    FILE_SERVER_RUNTIME_DATA :    STRUCT
        TIME_FILE_OPEN_CUR : UDINT; (**)
        TIME_FILE_OPEN_MAX : UDINT; (**)
        TIME_FILE_OPEN_MIN : UDINT; (**)
        TIME_FILE_CLOSE_CUR : UDINT; (**)
        TIME_FILE_CLOSE_MAX : UDINT; (**)
        TIME_FILE_CLOSE_MIN : UDINT; (**)
        TIME_FILE_READ_CUR : UDINT; (**)
        TIME_FILE_READ_MAX : UDINT; (**)
        TIME_FILE_READ_MIN : UDINT; (**)
        TIME_FILE_WRITE_CUR : UDINT; (**)
        TIME_FILE_WRITE_MAX : UDINT; (**)
        TIME_FILE_WRITE_MIN : UDINT; (**)
        TIME_FILE_SEEK_CUR : UDINT; (**)
        TIME_FILE_SEEK_MAX : UDINT; (**)
        TIME_FILE_SEEK_MIN : UDINT; (**)
        TIME_FILE_TELL_CUR : UDINT; (**)
        TIME_FILE_TELL_MAX : UDINT; (**)
        TIME_FILE_TELL_MIN : UDINT; (**)
        TIME_FILE_DELETE_CUR : UDINT; (**)
        TIME_FILE_DELETE_MAX : UDINT; (**)
        TIME_FILE_DELETE_MIN : UDINT; (**)
    END_STRUCT;
END_TYPE