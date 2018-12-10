import {
    MAX_DATA_POINTS,
    SET_DEVICE_SN,
    GET_DEVICE_DATA_SUCCESS,
    GET_DEVICE_DATA_ERROR,
    SET_TIME_OFFSET,
    GET_DEVICE_DATA_REQUEST
} from '../actions/DeviceActions';

const initialState = {
    deviceConnected: true,
    deviceData: [],
    establishingFirebaseConnection: false,
    connectedToFirebase: false,
    wifiForm: {
        ssid: '',
        pw: '',
        networkType: '1',
        hidePw: true,
        error: null
    },
    lastUpdate: '',
    offset: 0
};

export default function DeviceReducer(state = initialState, action) {
    switch (action.type) {
        case SET_DEVICE_SN: {
            return {...state, deviceSN: action.sn};
        }

        case GET_DEVICE_DATA_REQUEST: {
            return {...state, establishingFirebaseConnection: true, connectedToFirebase: false}
        }

        case GET_DEVICE_DATA_ERROR: {
            return {...state, establishingFirebaseConnection: false, connectedToFirebase: false}
        }

        case SET_TIME_OFFSET: {
            return {...state, offset: action.offset}
        }

        case GET_DEVICE_DATA_SUCCESS: {
            const datapoint = action.data[Object.keys(action.data)[0]];
            let updatedData = [...state.deviceData];
            if (updatedData.length >= MAX_DATA_POINTS) {
                /* slice data array so it's one below max*/
                updatedData = updatedData.slice(updatedData.length - (MAX_DATA_POINTS - 1))
            }
            updatedData.push(datapoint);
            return {
                ...state,
                deviceData: updatedData,
                lastUpdate: Date.now() + state.offset,
                connectedToFirebase: true,
                establishingFirebaseConnection: false
            }
        }

        default:
            return state;
    }
}
