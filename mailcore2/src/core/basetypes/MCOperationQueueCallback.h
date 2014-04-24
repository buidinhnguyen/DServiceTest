//
//  MCOperationQueueCallback.h
//  mailcore2
//
//  Created by DINH Viêt Hoà on 6/22/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#ifndef MAILCORE_OPERATIONQUEUECALLBACK_H
#define MAILCORE_OPERATIONQUEUECALLBACK_H

namespace mailcore {
    
    class OperationQueue;
    
    class OperationQueueCallback {
    public:
        virtual void queueStartRunning() {}
        virtual void queueStoppedRunning() {}
    };
    
}

#endif
