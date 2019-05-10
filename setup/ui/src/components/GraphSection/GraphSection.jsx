import React from 'react'
import { connect } from 'react-redux'
import { ThreeBounce } from 'better-react-spinkit'
import TileInset from '../TileInset/TileInset'
import InfoSection from '../InfoSection/InfoSection'
import { NumericalGraph } from '../graph/Graph'
import { deviceManager } from '../../actions/DeviceActions'

import './GraphSection.less';

class GraphSection extends React.Component {

  renderGraphs( deviceData, loading ) {
    const loadingAnimation = <div className="graphs-loading"><ThreeBounce size={13} color="#4285F4" /></div>
    if ( loading ) {
      return loadingAnimation
    }

    // return array of graphs, with one graph for each non-time data type in device data
    const graphs = [];
    let dataTypes = []

    // get array of non-time keys in data
    if ( deviceData && deviceData[0] ) {
      dataTypes = Object.keys( deviceData[0] ).filter( key => key !== 'time' )
    }

    // display error if no graphable data received
    if ( !dataTypes.length ) {
      graphs.push( 
        <TileInset title="No graphable data detected" className="graph graphs-left">
          <p>We successfully connected to Firebase, but did not find time sequenced numerical data.</p>
        </TileInset>
      )
      return graphs
    }

    // create graph for each dataType
    dataTypes.forEach( ( dataType, index ) => {
      let graphData
      const position = index % 2 === 0 ? 'left' : 'right'

      // if data not loaded, display loading animation instead of chart
      if ( loading ) {
        graphData = loadingAnimation
      } else {
        graphData = <NumericalGraph dataType={dataType} deviceData={deviceData} />
      }
      const graph = (
        <TileInset title={dataType} className={`graph graphs-${position}`}>
          { graphData }
        </TileInset>
      )
      graphs.push( graph )

    } )
    return graphs
  }

  render() {
    const { deviceData, firebaseAnimationComplete } = this.props
    const device = deviceManager.device
    const charts = this.renderGraphs( deviceData, !firebaseAnimationComplete )

    return (
      <InfoSection className="graphs" title={`Device UID: ${device}`}>
        <div className="graphs-wrapper">
          { charts }
        </div>
      </InfoSection>
    )
  }
}

const mapStateToProps = state => ( {
  deviceData : state.DeviceReducer.deviceData,
  connectedToFirebase : state.DeviceReducer.connectedToFirebase,
  firebaseAnimationComplete : state.UIReducer.animationComplete.firebase,
} )

export default connect( mapStateToProps )( GraphSection )
