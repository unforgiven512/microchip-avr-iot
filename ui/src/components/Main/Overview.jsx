import React from 'react';
import connectedDevices from '../../images/connected-devices.png'
import Button from '../Button/Button'

import './Overview.less';

export default class Overview extends React.Component {
    render() {
        return (
            <div className="overview-wrapper">
                <section className="overview">
                    <div className="overview-image">
                        <img src={connectedDevices} alt="" />
                    </div>
                    <div className="overview-text">
                        <h3>Building a Solution at Scale?</h3>
                        <p>Whether you're a Fortune 500 company or startup, transforming your current business or
                            creating entirely new businesses, it takes a team with deep experience across verticals and
                            use cases to turn your IoT prototype into an IoT product.</p>
                        <Button href="https://www.leverege.com/contact-us" text="Talk to an Expert" color="blue" />
                        <h3>What's Unforgiven Development all about?</h3>
                        <p>Over at Unforgiven Development, we enjoy exploring many different technologies; these
                            technologies range from embedded hardware development with microcontrollers and FPGAs, IoT
                            applications and wireless technologies, all the way to system administration, virtualization
                            and network infrastructure management.</p>
                        <Button href="https://unforgivendevelopment.com" text="Check out our Website" color="blue" />
                    </div>
                </section>
            </div>
        )
    }
}
